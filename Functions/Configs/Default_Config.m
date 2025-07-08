function config = Default_Config
% ---------------------------
% Analysis - WIND OPTIONS
% ---------------------------
config.use_extrapolated_wind_data = true;
config.use_exact_w_s = true; % Controls if the exact wind speed is used or  the wind is placed into bins and then the average of that bin is used


% ---------------------------
% Analysis - TURBINE OPTIONS
% ---------------------------
config.turbine_used = "15MW";% Gives which turbine is considered by the analysis options: [3MW] WINDPACT Turbine, [5MW] NREL Turbine and [15MW] NREL Turbine
config.coating_used = 'ThreeM'; % Alters the coating properties used in the analysis, options: [AAP] (from the RENER2024 paper), [ThreeM] (Case 2 in Sanchez Et al), [ORE] (Case 3 in Sanchez Et al)
config.consider_all_strips = false; % Controls if all strips are calculated or just the outermost one
% ---------------------------
% Analysis - RAINFALL OPTIONS
% ---------------------------
config.use_filtered_data = true;
config.consider_terminal_velocities = true; % If false sets all terminal velocities to 1, as is done in the joint FDF
config.use_measured_terminal_velocites = false; % If considering terminal velocities, use measured rather than emperical
config.use_best_distribution_simulation = false;
config.ommit_first_droplet_class = true;
config.ommit_lowest_rainfall_rates = true;

% ---------------------------
% Analysis - DATASET USED
% ---------------------------
config.location_considered = "UNSET"; % Determines which location is being analysed, options: [Lancaster], [Lecce], [Lampedusa], [North_Sea]
config.DT = 10; % Temporal Resolution of the Data, expressed in minutes

fdf_plotting_variables = ["Droplet_Diameter_Damage","Droplet_Diameter_Incident","Mass_Weighted_Diameter_Damage","Mass_Weighted_Diameter_Incident","Rainfall_Damage","Rainfall_Incident","Median_Diameter_Damage","Median_Diameter_Incident"];
config.fdf_variable_chosen = []; % Can either be a vector of all graphs to produce or a scalar 
config.normalise_plot = 1; % 1 for true 0 for false - Could do with changing



% ---------------------------
% Analysis - PRECIPITATION REACTIVE CONTROL
% ---------------------------
config.enable_PRC = false;
config.curtailing_wind_speed = 9; % The percentage of maximum rotor speed Turbine Operates at during curtailing
config.use_best_distribution_PRC = false; % Controls if Best distribution is used to find curtailing locations, or Measured is used. Damage should allways be calculated based upon measured

config.curtailing_criteria = ["Dm","D0","Rainfall","Dm_Rainfall","D0_Rainfall","Damage"];
config.curtailing_criteria_chosen = 3;

% Rain Metric Criteria
config.curtailing_lower_criteria =1;
config.curtailing_upper_criteria = 2;


% Wind Metric Criteria
config.curtailing_wind_speed_lower = 9; % Min value should be 3
config.curtailing_wind_speed_upper = 25; % Max value should be 25

% Rainfall
config.curtailing_rainfall_lower =0.1;
config.curtailing_rainfall_upper = 13.9364;

% Damage Criteria
config.lifetime_extention_multiplier = 12; % For idealised case 

% ---------------------------
% Analysis - PLOTTING OPTIONS
% ---------------------------
config.plot_fdf = true; % Controls if the simulation is plotted or if just damage values are shown


config.query_doing_PRC_analysis = "Non-PRC"; % Set either PRC or Non-PRC - changes file save location
config.version_number = "DEFAULT";
end