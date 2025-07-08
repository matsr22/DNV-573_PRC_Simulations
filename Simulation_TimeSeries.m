addpath(genpath('Functions\'))

%
% Configuration of the Simulation
%

config = Default_Config;

config= Set_Lampedusa(config);

Main_Algorithm(config,folder_save_location,global_run_number);







