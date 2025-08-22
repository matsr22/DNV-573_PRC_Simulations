close all;

addpath(genpath('Functions\'));

config = Config();

config.version_number = "Thesis-Temporal-Variation";
config.normalise_plot = 1;
% Control if BEST is used for curtailing locations
config.use_best_distribution_PRC = false;



config.query_doing_PRC_analysis = "PRC";

config.curtailing_wind_speed =8;
config.use_extrapolated_wind_data = false;

location_considered = "Lancaster_60";

if config.use_best_distribution_PRC && location_considered == "North_Sea"
    config.use_best_distribution_simulation = true;
end

config.Set_Location(location_considered);

% SELECT Curtailing Type
initial_curt_criteria_chosen = 3;
config.curtailing_criteria_chosen = initial_curt_criteria_chosen;
FDF_type = config.curtailing_criteria(config.curtailing_criteria_chosen);

if initial_curt_criteria_chosen == 1
    dmass_rainfall = "dmass";
elseif initial_curt_criteria_chosen ==3
    dmass_rainfall = "rainfall";
else
    error("Curtailing Method not setup")
end

target_damage_reduction = 0.5; % Target damage reduction as a fraction
target_percentage_increase_life =  (1/(1-target_damage_reduction))*100 - 100;
% Load Initial Uncurtailed Results:

config.fdf_variable_chosen = 1; % Plot against true DSD for uncurt

config.query_iterate = true;

uncurt_result = Main_Algorithm(config);
uncurt_tot_damage = sum(uncurt_result.damage_matrix,"all");
config.fdf_variable_chosen = [];

config.query_iterate = false;


[w_calc,~] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
% Generate Non Graphical FDF 
[damages_FDF,incident_FDF,~,parameter_bins] = Construct_FDFs(config,w_calc,uncurt_result.wind_velocities,uncurt_result.damage_matrix,uncurt_result.d_bins,uncurt_result.d_calc,uncurt_result.n_droplets_air,FDF_type);

parameter_mids =( parameter_bins(1:end-1) + parameter_bins(2:end))/2;
candidate_strips = damages_FDF(config.curtailing_wind_speed:end,:); % Works only for integer wind speeds

strip_vals = sum(candidate_strips,1); % TOtal damage for each horizontal strip
cumsum_strips_flipped = cumsum(flip(strip_vals));


target_damage_red_true = target_damage_reduction*uncurt_tot_damage;

algorithm_start_index = length(strip_vals)+3 - find(cumsum_strips_flipped > target_damage_red_true,1,"first"); % Find first place that we will get close to that damage


index_low = algorithm_start_index;
index_high = length(strip_vals)+1;



config.enable_PRC = true;

SetParameter(config,parameter_bins(index_low),"lower",dmass_rainfall)
SetParameter(config,1000,"upper",dmass_rainfall)


current_result = Main_Algorithm(config);



previous_damage_removed = 0;
prev_curt_critera = GetParameter(config,"upper",dmass_rainfall);
current_damage_removed = uncurt_tot_damage - sum(current_result.damage_matrix,"all");

parameter_stepsize = 0.4;


while abs(previous_damage_removed - current_damage_removed) / uncurt_tot_damage > 1e-4

    if current_damage_removed > target_damage_red_true
        parameter_stepsize = parameter_stepsize/2;
        SetParameter(config,prev_curt_critera - parameter_stepsize,"lower",dmass_rainfall);
        current_result = Main_Algorithm(config);
        current_damage_removed = uncurt_tot_damage - sum(current_result.damage_matrix,"all");

        continue
    end
    
    if GetParameter(config,"lower",dmass_rainfall) - parameter_stepsize < parameter_bins(1)
        SetParameter(config,parameter_bins(1),"lower",dmass_rainfall);
    elseif GetParameter(config,"lower",dmass_rainfall) == parameter_bins(1)
        error("No More Curtailing Possible")
    else
        prev_curt_critera = GetParameter(config,"lower",dmass_rainfall);
        SetParameter(config,prev_curt_critera - parameter_stepsize,"lower",dmass_rainfall);
    end
          
    
    previous_result = current_result;
    current_result = Main_Algorithm(config);
    previous_damage_removed = current_damage_removed;
    current_damage_removed = uncurt_tot_damage - sum(current_result.damage_matrix,"all");


end

if abs(target_damage_red_true-current_damage_removed) > abs(target_damage_red_true -previous_damage_removed)    
    SetParameter(config,prev_curt_critera,"lower",dmass_rainfall);
end



[current_result,prc_result] = Main_Algorithm(config); % Plot and Save Appropriate Graphs
locations_prc = prc_result.locations;
final_damage_removed = uncurt_tot_damage - sum(current_result.damage_matrix,"all");



% Damage Based Equivilent Curtailing
total_size_dataset = size(current_result.damage_matrix,1);

index_sweep_size = ceil(total_size_dataset/100);
current_number_damage_elements = index_sweep_size;
previous_num_damage_elements = 1;

config.curtailing_criteria_chosen = 6; % Damage Based
config.fdf_variable_chosen = [];

while index_sweep_size >0
    config.damage_number_elements_curtail = current_number_damage_elements;

    [ideal_curt_result,ideal_prc_result] = Main_Algorithm(config,uncurt_result);

    damage_removed = uncurt_tot_damage -sum(ideal_curt_result.damage_matrix,"all");

    if damage_removed > final_damage_removed && index_sweep_size > 1
        index_sweep_size = ceil(index_sweep_size/2);
        current_number_damage_elements = previous_num_damage_elements +index_sweep_size;
    elseif damage_removed <  final_damage_removed
        previous_num_damage_elements = current_number_damage_elements;
        current_number_damage_elements=current_number_damage_elements + index_sweep_size;
    elseif damage_removed > final_damage_removed && index_sweep_size ==1
        break
    else
        error("Conditon Should not be reached")

    end

end
locations_ideal = ideal_prc_result.locations;
config.curtailing_criteria_chosen = initial_curt_criteria_chosen;
Save_Close_PRC_data(config,uncurt_result,current_result,ideal_curt_result,prc_result,ideal_prc_result,...
    target_percentage_increase_life);
Gen_PRC_LaTeX(config,uncurt_result,current_result,ideal_curt_result,prc_result,ideal_prc_result);


% Add plot with lines drawn 
if initial_curt_criteria_chosen == 1
    config.fdf_variable_chosen = 3;
elseif initial_curt_criteria_chosen ==2
    config.fdf_variable_chosen = 9;
elseif initial_curt_criteria_chosen ==3
    config.fdf_variable_chosen = 6;
else
    error("Curtailing Method not setup")
end


if ~config.use_best_distribution_PRC
config.plot_hor_lim_line = true;
config.enable_PRC = false;
Main_Algorithm(config);
config.enable_PRC = true;
Main_Algorithm(config);
config.plot_hor_lim_line = true;
end

close all;

function result = GetParameter(config,lower_upper,dmass_rainfall)
    if lower_upper == "lower" & dmass_rainfall == "rainfall"
        result = config.curtailing_rainfall_lower;
    elseif lower_upper == "upper" & dmass_rainfall == "rainfall"
        result = config.curtailing_rainfall_upper;
    elseif lower_upper == "lower" & dmass_rainfall == "dmass"
        result = config.curtailing_lower_criteria;
    elseif lower_upper == "upper" & dmass_rainfall == "dmass"
        result = config.curtailing_upper_criteria;
    end
end

function SetParameter(config,value,lower_upper,dmass_rainfall)
    if lower_upper == "lower" & dmass_rainfall == "rainfall"
        config.curtailing_rainfall_lower = value;
    elseif lower_upper == "upper" & dmass_rainfall == "rainfall"
        config.curtailing_rainfall_upper = value;
    elseif lower_upper == "lower" & dmass_rainfall == "dmass"
        config.curtailing_lower_criteria = value;
    elseif lower_upper == "upper" & dmass_rainfall == "dmass"
        config.curtailing_upper_criteria = value;
    end
end
