function Main_Algorithm(config,global_run_number)
% ---------------------------
% Analysis - Main Algorithm
% ---------------------------

if config.plot_fdf
    [global_run_number,folder_save_location] = Generate_Save_Location(config);
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

[suffix2,d_calc,d_bins,data_quantity_days,n_droplets_air,wind_velocities] = Load_All_Files(config,suffix);

for i = strip_index


% Convert the wind speeds to the corresponding speed of the blade at a
% each indexuse

% PRECIPITATION REACTIVE CONTROL 

if config.enable_PRC
    if config.location_considered == "North_Sea"
        n_droplets_air_PRC = n_droplets_air;
    elseif config.use_best_distribution_simulation == true
        error("Best distribution should not be used for damage simulation of PRC control")
    elseif config.use_best_distribution_simulation == config.use_best_distribution_PRC % Both Measured
        n_droplets_air_PRC = n_droplets_air;
    else % PRC applied to Best Distribution
        suffix = "best";
        wind_droplet_table = Unpack_Wind_Rain_Data(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\",config.location_considered,"\",string(config.DT),"min_data_",suffix,suffix2,".mat"),config.ommit_first_droplet_class,config.ommit_lowest_rainfall_rates); 
        col_names = "dsd_" + string(0:21);
        n_droplets_air_PRC = wind_droplet_table{:, col_names};
    end
       
    % Prep the dataset for PRC - Calculate Mass_W_Diameter, Rainfall and
    % Median. 

    d_widths = d_bins(2:end)-d_bins(1:end-1);

    mass_weighted_diameters = sum((n_droplets_air_PRC./d_widths).*d_calc.^4,2)./sum((n_droplets_air_PRC./d_widths).*d_calc.^3,2); % Gets the mass weighted diameter for each

    rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air_PRC,d_calc); 
    
    [~,~,medians] = Calculate_Mmass(d_bins,n_droplets_air,d_calc);

    [uncurt_damage,damage_criteria,time_series_damage_uncurt,AEP_uncurt] = Get_Uncurtailed_Data(config.location_considered,config.use_best_distribution_simulation,config.lifetime_extention_multiplier);
    
    switch config.curtailing_criteria_chosen
        case 1
            curtailing_locations = mass_weighted_diameters >= config.curtailing_lower_criteria & mass_weighted_diameters <= config.curtailing_upper_criteria & config.curtailing_wind_speed_lower < wind_velocities & config.curtailing_wind_speed_upper > wind_velocities ;
            config.curtailing_rainfall_lower = "-";
            config.curtailing_rainfall_upper = "-";
        case 2
            curtailing_locations = medians >= config.curtailing_lower_criteria & medians <= config.curtailing_upper_criteria & config.curtailing_wind_speed_lower < wind_velocities & config.curtailing_wind_speed_upper > wind_velocities;
            config.curtailing_rainfall_lower = "-";
            config.curtailing_rainfall_upper = "-";        
        case 3
            curtailing_locations = rainfalls > config.curtailing_rainfall_lower & rainfalls <= config.curtailing_rainfall_upper & config.curtailing_wind_speed_lower < wind_velocities & config.curtailing_wind_speed_upper > wind_velocities;
            config.curtailing_lower_criteria = "-";
            config.curtailing_upper_criteria = "-";
        case 4
            curtailing_locations = rainfalls > config.curtailing_rainfall_lower & rainfalls <= config.curtailing_rainfall_upper &mass_weighted_diameters >= config.curtailing_lower_criteria & mass_weighted_diameters <= config.curtailing_upper_criteria & config.curtailing_wind_speed_lower < wind_velocities & config.curtailing_wind_speed_upper > wind_velocities ;
        case 5
            curtailing_locations = rainfalls >= config.curtailing_rainfall_lower & rainfalls <= config.curtailing_rainfall_upper & medians >= config.curtailing_lower_criteria & medians <= config.curtailing_upper_criteria & config.curtailing_wind_speed_lower < wind_velocities & config.curtailing_wind_speed_upper > wind_velocities;

        case 6
            curtailing_locations = time_series_damage_uncurt >= damage_criteria;
        otherwise 
            error("Selected curtailing criteria does not exist")
    end
    
    [impact_velocities, powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),config.turbine_used,config.curtailing_wind_speed,curtailing_locations);
    time_curtailed = (sum(curtailing_locations)*config.DT)/(60*24); % Time in Days Curtailed 
    data_quantity_curtailed = sum(curtailing_locations);
    AEP_curt = sum(2.77778e-10*(powers*config.DT*60)); % Units of MWH

    percentage_energy_loss = 100*((AEP_uncurt-AEP_curt)./(AEP_uncurt));
    


else

[impact_velocities,powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),config.turbine_used);
end


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
    global_damage = total_damage;
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

% ROADWORKS - this currently looks useless but is used as a workspace
% variable in the function to calculate curtailing criterion
if config.use_best_distribution_simulation
    title_part = "Best";
else
    title_part = "Measured";
end


disp('Incubation Time Predicted:')

disp(strip_hours(strip_index))

years = strip_hours / (365.25 * 24);
formatted_values = arrayfun(@(x) sprintf('& %+0.1f ', x), years, 'UniformOutput', false);
latex_row = [strjoin(formatted_values) '\\'];
clipboard('copy', latex_row);

if config.enable_PRC
    Save_Close_PRC_data(uncurt_damage,total_damage,data_quantity_days,strip_hours,wind_velocities,config,AEP_uncurt,AEP_curt,time_curtailed,folder_save_location,global_run_number);
end
end