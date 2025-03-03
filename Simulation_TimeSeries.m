
clear
clc
close all

% Load in time series data:
DT = 10; % Time step of the data expressed in minutes

imported_structure = struct2cell(load(append("Simulation_Data\Time_Series\",string(DT),"min_data_flatten.mat")));% Using the non-filtered data to match the joint FDF
wind_droplet_table = imported_structure{1};
d_bins = imported_structure{2};
terminal_v_bins = [imported_structure{3} 100]; % The last index is added for the bin that exists to infinity. 

wind_droplet_table = RestructureTable(wind_droplet_table); % Adjusts the table so that the correct time frame is used


% Generates a vector of the variables of the joint size velocity
% distribution indexes
for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end

% Gets the collumns of the joint SVD from the table
svd = wind_droplet_table{:,svd_indexing};
svdSize = size(svd);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd = reshape(svd', 20, 22, svdSize(1));  



% The diameters and velocities assosiated with each of the bins in svd 
Dm = (d_bins(1:(end-1)) + d_bins(2:end))./2;

Vm = (terminal_v_bins(1:(end-1)) + terminal_v_bins(2:end))./2;

% Wind speed at each timestep
wind_velocities = wind_droplet_table{:,"wind_avg"};

% Convert the wind speeds to the corresponding speed of the blade at a
% each index

strip_radius = 60.8; % Gives the radius of the strip being considered 60.8 corresponds to strip 6 in the paper

blade_velocities = WindToBladeVelocity(wind_velocities,strip_radius);

% Create matrix of number of droplets incident on blade per m^2
A = 0.0046; % area in m^2 of impact area

[svd_diameters,svd_vels] = meshgrid(Dm,Vm); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point

svd_vals = 1; % Initially assume that droplet diameters are all 1 m/s as
svd = svd./(A.*1); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later)

n_droplets_air = sum(svd,1); % Sum across all droplet terminal velocities

n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

n_s = n_droplets_air .* blade_velocities; % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)


% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.
[diameter_mesh,blade_vel_mesh] = meshgrid(Dm,blade_velocities); 


computed_vals = GetSpringerStrength(); % Sets up the springer strength (Given in the RENER paper)

allowed_impingements = CalculateAllowedImpingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination

damages = n_s./allowed_impingements; 

time_series_damage = sum(damages,2); % Gets the damage for every timestep

cumSumDamages = cumsum(time_series_damage); % Vector of the accumalated damage over time

total_damage = sum(damages,'all');


Hours  = (1/total_damage)*365.24*24 % Prints number of hours of the incubation time


function new_table = RestructureTable(table)

    % This function removes data not in the domain of the 1 year we are
    % looking for. 

    t_vals = table{:,"dateTime"};
    t_vals = datetime(t_vals);

    % Find the indexes in the table that correspond to First time step of
    % October 2018 and last time step of 30 Sep 2019

    target_start_year = 2018;
    target_start_month = 10;
    start_day_index = find(year(t_vals) == target_start_year & month(t_vals) == target_start_month, 1, 'first');

    
    
    target_end_year = 2019;
    target_end_month = 9;
    target_end_day = 30;
    
    end_day_index = find(year(t_vals) == target_end_year & month(t_vals) == target_end_month & day(t_vals) == target_end_day , 1, 'last');

    % Now fill in the missing data

    % In the RENER24 Paper, data is described as missing between the 22nd
    % and 26th of Sep 2019. This is accurate
    % However it says to fill in use the corresponding dates in 2017. This
    % data also does not exist.

    % For now I will ignore as it will be a small modification


    
    new_table = table(start_day_index:end_day_index,:);


end

