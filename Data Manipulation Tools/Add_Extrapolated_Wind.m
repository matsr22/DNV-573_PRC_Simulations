

base_data = load('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_filt.mat');
extrap_data = load('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Wind_Data\Lancaster_Extrapolated_Wind_Data.mat');

base_data_table1 = base_data.data_10_min_filt_merged;
base_data_table2 = base_data_table1;
extrap_data_low = extrap_data.extrapolated_data.Wind_119m;
extrap_data_high = extrap_data.extrapolated_data.Wind_150m;

wind_data = base_data_table1.wind_avg;

wind_data_low = extrap_data_low(1:length(wind_data));
wind_data_high = extrap_data_high(1:length(wind_data));

base_data_table1.wind_avg = wind_data_low;
base_data_table2.wind_avg = wind_data_high;

data_low = base_data;
data_high = base_data;

data_low.Lampedusa_filt_10min_data = base_data_table1;
data_high.Lampedusa_filt_10min_data = base_data_table2;

save('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_filt_119_ext.mat','-struct','data_low')
save('C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_filt_150_ext.mat','-struct','data_high')