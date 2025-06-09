

base_data = load('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lampedusa\10min_data_filt.mat');
extrap_data = load('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Wind_Data\Lampedusa_Extrapolated_Wind_Data.mat');

base_cell_array = struct2cell(base_data);

base_data_table1 = base_data.Lampedusa_filt_10min_data;
base_data_table2 = base_data_table1;
extrap_data_low = extrap_data.extrapolated_data.Wind_119m;
extrap_data_high = extrap_data.extrapolated_data.Wind_150m;

wind_data = base_data_table1.wind_avg;

wind_data_low = extrap_data_low(1:length(wind_data));
wind_data_high = extrap_data_high(1:length(wind_data));

base_data_table1.wind_avg = wind_data_low;
base_data_table2.wind_avg = wind_data_high;

data_low_cells = {base_data_table1,base_cell_array{2}, base_cell_array{3}};
data_high_cells = {base_data_table2,base_cell_array{2}, base_cell_array{3}};

data_low = cell2struct(data_low_cells,["data_table","droplet_diameter_bins","droplet_velocity_bin"],2);
data_high = cell2struct(data_high_cells,["data_table","droplet_diameter_bins","droplet_velocity_bin"],2);
save('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lampedusa\10min_data_filt_119_ext.mat','-struct','data_low')
save('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lampedusa\10min_data_filt_150_ext.mat','-struct','data_high')