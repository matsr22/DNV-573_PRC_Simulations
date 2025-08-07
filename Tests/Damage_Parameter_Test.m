

addpath(genpath('..\Functions\'))
addpath(genpath('..\Simulation_Data\'))
addpath(fileparts(pwd));

config = Config();

config.normalise_plot = 1;

plotting_variables = [];

location = "North_Sea";

use_best = true;

config.Set_Location(location);

config.use_best_distribution_simulation = true;

test_result_damages = Main_Algorithm(config);

config.use_best_distribution_simulation = use_best;

test_result_air_drops = Main_Algorithm(config);

damage_time_series = sum(test_result_damages.damage_matrix,2);

n_droplets_air = test_result_air_drops.n_droplets_air;

rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air,test_result_damages.d_calc) * 6; % Convert from the DT of 10 minutes to per hour 

dmasses = Calculate_Dmass(n_droplets_air,test_result_damages.d_calc,test_result_damages.d_bins);
dmasses(isnan(dmasses)) = 0;

damage_time_series = damage_time_series / sum(damage_time_series);

loglog(rainfalls,damage_time_series,'x','MarkerSize',3)

xlabel('$D_m [mm]$', 'Interpreter', 'latex','FontSize', 16)
ylabel('$D_s / D_{s,T}$', 'Interpreter', 'latex','FontSize', 16)
ylim([1e-8 1e-2])
xlim([0.3 2])