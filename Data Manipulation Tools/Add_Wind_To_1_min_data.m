% Extrapolates the wind data from the 10 minute data to the 1 minute data -
% applies uniformally across the timestep
clc;
clear

one_minute_source = fullfile(fileparts(fileparts(mfilename('fullpath'))),"Simulation_Data","Lancaster","data1min_filt.mat");
ten_minute_source = fullfile(fileparts(fileparts(mfilename('fullpath'))),"Simulation_Data","Lancaster","10min_data_filt.mat");

one_minute_data = load(one_minute_source);
ten_minute_data = load(ten_minute_source);

temp = struct2cell(one_minute_data);
data_table_1_min = temp{1};

temp = struct2cell(ten_minute_data);
data_table_10_min = temp{1};



data_table_1_min.dateTime = datetime(data_table_1_min.dateTime);
data_table_10_min.dateTime = datetime(data_table_10_min.dateTime);


dates_1_min_rounded = data_table_1_min.dateTime;

dates_1_min_rounded.Minute = minute(data_table_1_min.dateTime)-rem(minute(data_table_1_min.dateTime),10);
data_table_1_min_rounded = data_table_1_min;

data_table_1_min_rounded.dateTime = dates_1_min_rounded;

data_table_10_min_wind_data = data_table_10_min(:, {'dateTime', 'wind_avg'});

final_table = innerjoin(data_table_1_min_rounded,data_table_10_min_wind_data,"Keys","dateTime");

final_dsd_0 = final_table.dsd_0;
sum(final_dsd_0(~isnan(final_dsd_0)))

sum(ten_minute_data.data_10_min_filt_merged.dsd_0)
