vars = load("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\North_Sea\10min_data_best.mat");
vars.NorthSea_merged_wind_10min_data.Properties.VariableNames{'wind_avg_119'} = 'wind_avg';

table = vars.NorthSea_merged_wind_10min_data;
dsd_bins = vars.droplet_diameter_bins;
dvd_bins = vars.droplet_velocity_bin;

data_to_save = {table,dsd_bins, dvd_bins};

data_struct = cell2struct(data_to_save,["data_table","droplet_diameter_bins","droplet_velocity_bin"],2);

save("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\North_Sea\10min_data_best_119_ext.mat",'-struct','data_struct');


