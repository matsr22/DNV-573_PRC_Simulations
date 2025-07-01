DT = 1;

% Extract 1_min_data

[table1,d_calc,d_bins] = Unpack_Wind_Rain_Data("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\1min_data_extended.mat",false);

table10 = Unpack_Wind_Rain_Data("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_filt.mat",false);

table1.dateTime = datetime(table1.dateTime);
table10.dateTime = datetime(table10.dateTime);

% Preallocate logical index array
matchIdx = false(height(table1), 1);

% Initialize waitbar
h = waitbar(0, 'Filtering 1-minute data...');

% Loop through each 10-minute start time
for i = 1:height(table10)
    % Define the 10-minute window
    startT = table10.dateTime(i);
    endT = startT + minutes(10);
    
    % Mark matching rows in the logical index
    matchIdx = matchIdx | (table1.dateTime >= startT & table1.dateTime < endT);
    
    % Update progress bar every 5% or so
    if mod(i, round(height(table10)/20)) == 0
        waitbar(i / height(table10), h);
    end
end

% Close the waitbar
close(h);

% Extract only matching rows from table1
table1_trimmed = table1(matchIdx, :);