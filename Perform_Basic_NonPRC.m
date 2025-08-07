close all;

addpath(genpath('Functions\'))

%
% Configuration of the Simulation
%

config = Config();

config.turbine_used = "5MW";
config.coating_used = "AAP";
config.use_filtered_data = false;
config.use_measured_terminal_velocites = true;
config.ommit_first_droplet_class = false;
config.location_considered = "Lancaster";
config.plot_fdf = false;
config.use_extrapolated_wind_data = false;
config.consider_terminal_velocities = true;
Main_Algorithm(config);