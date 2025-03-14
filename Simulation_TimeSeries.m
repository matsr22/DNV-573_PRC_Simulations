
clear
clc
close all
%
% Configuration of the Simulation
%

use_filtered_data = true;
consider_all_strips = true; % Controls if all strips are calculated or just the outer one
consider_terminal_velocities = false; % If false sets all terminal velocities to 1, as is done in the joint FDF
simplify_to_fdf = false; % Controls if the exact wind speed is used or if the same bins as used in the RENER joint FDF are used
DT = 60; % Time step of the data expressed in minutes


strip_radii = [45.15 49.25 53 56.05 58.75 60.8]; % Strips, indexed 1 to 6 of those considered in the paper


if use_filtered_data
    suffix = "filt";
else
    suffix = "unfilt";
end

if consider_all_strips
    strip_index = 1:6;
else
    strip_index = 6;
end

%
% Import Data
%

imported_structure = struct2cell(load(append("Simulation_Data\Time_Series_Lancaster\",string(DT),"min_data_",suffix,".mat")));% Using the non-filtered data to match the joint FDF


for i = strip_index

% Load in time series data:
wind_droplet_table = imported_structure{1};


d_bins = imported_structure{2}; % The bins provided are for the lower value of each bin. 
terminal_v_bins = [imported_structure{3} 10]; % The bins are provided for the upper value of each bin 


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
d_calc = d_bins; 

% Used to calculate the values for the terminal velocity - unused if
% assuming 1m/s
t_v_lower = [0 terminal_v_bins(1:end-1)];
t_v_calculations = (terminal_v_bins + t_v_lower)./2; % Currently Gets the midpoint of each of the terminal velocities



% Wind speed at each timestep
wind_velocities = wind_droplet_table{:,"wind_avg"};


% Places wind velocity into bins rather than using the exact value - for
% comparison purposes 
if simplify_to_fdf
 [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
 [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
 wind_velocities = w_calc(indices)';

end

% Convert the wind speeds to the corresponding speed of the blade at a
% each index

blade_velocities = WindToBladeVelocity(wind_velocities,strip_radii(i));

impact_velocities = sqrt(blade_velocities.^2 + wind_velocities.^2); % Remove DIFFERENCE

% Create matrix of number of droplets incident on blade per m^2
A = 0.00456; % area in m^2 of sensor

[svd_diameters,svd_vels] = meshgrid(d_calc,t_v_calculations); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point

if  ~ consider_terminal_velocities
    svd_vels = 1; % Initially assume that droplet diameters are all 1 m/s - to match with RENER. Remove this line to consider droplet terminal velocities.
end
svd = svd./(A.*svd_vels); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later - see Incident_Droplet_Calculations.pdf for an explanation)

n_droplets_air = sum(svd,1); % Sum across all droplet terminal velocities

n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

n_s = n_droplets_air .* impact_velocities; % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)


% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.
[diameter_mesh,blade_vel_mesh] = meshgrid(d_calc,impact_velocities); 


computed_vals = GetSpringerStrength(); % Sets up the springer strength (Given in the RENER paper)

allowed_impingements = CalculateAllowedImpingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination

damages = n_s./allowed_impingements; 

time_series_damage = sum(damages,2); % Gets the damage for every timestep

droplet_diameter_damage = sum(damages,1);

cumSumDamages = cumsum(time_series_damage); % Vector of the accumalated damage over time

total_damage = sum(damages,'all');

strip_damage(i) = total_damage;
strip_hours(i) = (1/total_damage)*365*24; % CHANGE MADE

end



ref_lifetimes = [30502 18597 12210 8846 6739 5524];



if simplify_to_fdf
% Re-construct FDF:
 
 FDF = zeros(length(w_calc),length(d_calc));
 
 for x=1:length(w_calc)
     wind = w_calc(x);
     mask = (wind_velocities == wind);
     FDF(x,:) = sum(n_s(mask, :), 1);
 
 end
 d_bins = [0 d_bins ]; % An incorrect display of the data but it is consistent with the rener paper
 %SpeedDropletPlot(d_bins,log10(FDF),"FDF - created");

 damages_FDF =  zeros(length(w_calc),length(d_calc));

 for x=1:length(w_calc)
     wind = w_calc(x);
     mask = (wind_velocities == wind);
     damages_FDF(x,:) = sum(damages(mask, :), 1);
 end

 SpeedDropletPlot(d_bins,damages_FDF,"n/N - Time Series")
 hold on;
clim([0 0.05]) % To match the damage scale used in the paper - for comparison
hold off;

end

disp('Incubation Time Predicted:')

ans =strip_hours(strip_index)

disp('Percentage difference between predicted and reference:')

100*(abs(strip_hours(strip_index)-ref_lifetimes(strip_index))./ref_lifetimes(strip_index))






