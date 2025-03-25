% Script to find the start and end indexes of the time frame with most
% data- minimise number of NaNs

DT = 10;

year_length_index = (60/DT)*24*365;

imported_structure = struct2cell(load(append("..\Simulation_Data\Lecce\Lecce_nofilt_",num2str(DT),"min_data.mat")));% Using the non-filtered data to match the joint FDF

wind_droplet_table = imported_structure{1};

wind_velocities = wind_droplet_table{:,"wind_avg"};

dsd0 = wind_droplet_table{:,"dsd_0"};

nan_indexes = isnan(wind_velocities);

total_rain_nan = sum(dsd0(nan_indexes))



dsd0nan = sum(isnan(dsd0));


min_data_loss = inf; 
best_idx = 1;    % Store the start index of the best period

% Slide over the vector and count NaNs
for i = 1:(length(wind_velocities) - year_length_index + 1)
    subvec = wind_velocities(i:i + year_length_index - 1);
    nan_count = sum(isnan(subvec));

    % Update if this subvector has fewer NaNs
    if nan_count < min_data_loss
        min_data_loss = nan_count;
        best_idx = i;
    end
end
year_lost = min_data_loss/year_length_index

max_complete_data = (length(wind_velocities) - sum(isnan(wind_velocities))) / year_length_index
min_data_loss
best_idx