function [result,prc_result] =  Main_Algorithm(config,prev_result)
% ---------------------------
% Analysis - Main Algorithm
% ---------------------------

if config.plot_fdf && ~isempty(config.fdf_variable_chosen)
    [folder_save_location,global_run_number] = Generate_Save_Location(config);
    result.global_run_number = global_run_number;
    result.folder_save_location =folder_save_location;
end

strip_radii = load(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Turbine_Curves\Turbine_Data_",config.turbine_used,".mat"),"radii"); % Strips, indexed 1 to 6 of those considered in the paper
strip_radii = strip_radii.radii;

if config.use_best_distribution_simulation
    suffix = 'best';
elseif config.use_filtered_data
    suffix = "filt";
else
    suffix = "unfilt";
end

if config.consider_all_strips
    strip_index = 1:6;
else
    strip_index = 6;
end


[suffix2,d_calc,d_bins,data_quantity_days,n_droplets_air,wind_velocities,wind_droplet_table] = Load_All_Files(config,suffix);

for i = strip_index


% Convert the wind speeds to the corresponding speed of the blade at a
% each indexuse

% PRECIPITATION REACTIVE CONTROL 

if config.enable_PRC
    if config.location_considered == "North_Sea"
        n_droplets_air_PRC = n_droplets_air;
        rainfalls = wind_droplet_table.rainfall_rate;
        

    elseif config.use_best_distribution_simulation == true
        error("Best distribution should not be used for damage simulation of PRC control")
    elseif config.use_best_distribution_simulation == config.use_best_distribution_PRC % Both Measured
        n_droplets_air_PRC = n_droplets_air;
        rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air,d_calc);
    else % PRC applied to Best Distribution
        suffix = "best";
        wind_droplet_table = Unpack_Wind_Rain_Data(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\",config.location_considered,"\",string(config.DT),"min_data_",suffix,suffix2,".mat"),config.ommit_first_droplet_class,config.ommit_lowest_rainfall_rates); 
        col_names = "dsd_" + string(0:21);
        n_droplets_air_PRC = wind_droplet_table{:, col_names};
    end
       
    % Prep the dataset for PRC - Calculate Mass_W_Diameter, Rainfall and
    % Median. 

    

    if config.curtailing_criteria_chosen == 6
        time_series_damages = sum(prev_result.damage_matrix,2);

        [~,indexes_damages] = sort(time_series_damages,"descend");
        temp_array = zeros(size(time_series_damages));
        curtailing_locations = indexes_damages(1:config.damage_number_elements_curtail);
        temp_array(curtailing_locations)=1;
        curtailing_locations = logical(temp_array);
        curtailing_locations = curtailing_locations & wind_velocities > config.curtailing_wind_speed_lower;

    else
    
    switch config.curtailing_criteria_chosen
        case 1
            curtailing_parameter = Calculate_Dmass(n_droplets_air_PRC,d_calc,d_bins); % Gets the mass weighted diameter for each
            rainfall_curt_enabled = false;
            dsd_curt_enabled = true;
        case 2
            [~,~,curtailing_parameter] = Calculate_Mmass(d_bins,n_droplets_air_PRC,d_calc);
            rainfall_curt_enabled = false;
            dsd_curt_enabled = true;
        case 3
            rainfall_curt_enabled = true;
            dsd_curt_enabled = false;
        case 4
            curtailing_parameter = Calculate_Dmass(n_droplets_air_PRC,d_calc,d_bins); % Gets the mass weighted diameter for each
            rainfall_curt_enabled = true;
            dsd_curt_enabled = true;
        case 5
            curtailing_parameter = Calculate_Mmass(n_droplets_air_PRC,d_calc,d_bins); % Gets the mass weighted diameter for each
            rainfall_curt_enabled = true;
            dsd_curt_enabled = true;  
             
    end
    curtailing_locations = true(size(n_droplets_air,1),1);
    if dsd_curt_enabled 
        curtailing_locations = curtailing_locations & curtailing_parameter >= config.curtailing_lower_criteria & curtailing_parameter <= config.curtailing_upper_criteria & wind_velocities > config.curtailing_wind_speed_lower;
    end
    if rainfall_curt_enabled
        curtailing_locations = curtailing_locations & rainfalls > config.curtailing_rainfall_lower & rainfalls <= config.curtailing_rainfall_upper & wind_velocities > config.curtailing_wind_speed_lower;
    end
    end

    
    

      
    
    [impact_velocities, powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),config.turbine_used,config.curtailing_wind_speed,curtailing_locations);
    prc_result.time_curtailed = (sum(curtailing_locations)*config.DT)/(60*24); % Time in Days Curtailed 
    prc_result.data_quantity_curtailed = sum(curtailing_locations);
    prc_result.locations = curtailing_locations;
    


else

[impact_velocities,powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),config.turbine_used);

end



result.AEP = sum(2.77778e-10*(powers*config.DT*60)); % Units of MWH
% Create matrix of number of droplets incident on blade per m^2

n_s = n_droplets_air .* impact_velocities.*(config.DT*60); % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)

% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.

[diameter_mesh,blade_vel_mesh] = meshgrid(d_calc,impact_velocities); 



computed_vals = Get_Springer_Strength(config.coating_used); % Sets up the springer strength (Given in the RENER paper) - Ideally move this and other similar preparation steps outside the loop


allowed_impingements = Calculate_Allowed_Impingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination


damages = n_s./allowed_impingements; 


time_series_damage = sum(damages,2); % Gets the damage for every timestep


droplet_diameter_damage = sum(damages,1); % Gets the damage for each droplet diameter

total_damage = sum(damages,'all');

if ~config.enable_PRC
    config.global_damage =total_damage;
    global_damage = total_damage;
else
    global_damage = config.global_damage;
end
strip_damage(i) = total_damage;
strip_hours(i) = (1/total_damage)*data_quantity_days*24; % This was one of the differences between the Rome research team's results and mine, I am using the correct slightly modified number of days in the dataset, they were using number of days in a year

end
%%

for i = 1:length(config.fdf_variable_chosen)
    Plotting_Algorithms(config,wind_velocities,config.fdf_variable_chosen(i),damages,d_bins,n_s,n_droplets_air,global_damage);
end

if ~isempty(config.fdf_variable_chosen) && config.plot_fdf
    Adjust_All_Colour_Bars(folder_save_location);
end


disp('Incubation Time Predicted:')

disp(strip_hours(strip_index))

strip_years = strip_hours / (365.25 * 24);
str = sprintf('%g\t', strip_hours);
str(end) = [];  % remove trailing tab
clipboard('copy', str);  % copy to clipboard


result.incubation_hours = strip_hours(end);
result.damage_matrix = damages;
result.n_droplets_air = n_droplets_air;
result.d_calc = d_calc;
result.d_bins = d_bins;
result.data_quantity_days = data_quantity_days;

result.wind_velocities = wind_velocities;

end