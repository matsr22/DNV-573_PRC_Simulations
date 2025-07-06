function [suffix2,d_calc,d_bins,data_quantity_days,n_droplets_air,wind_velocities] = Load_All_Files(config,suffix)
% Modifies the file accessed to be that specific to the hub height extrapolation
% required of each turbine. 5MW not added as this is not yet relevant to
% analysis we are doing. 
if config.use_extrapolated_wind_data
    if config.turbine_used == "3MW"
        suffix2 = "_119_ext";
    elseif config.turbine_used == "15MW"
        suffix2 = "_150_ext";
    end
end

%
% Import Data
%

[wind_droplet_table, d_calc,d_bins,terminal_v_bins] = Unpack_Wind_Rain_Data(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\",config.location_considered,"\",string(config.DT),"min_data_",suffix,suffix2,".mat"),config.ommit_first_droplet_class,config.ommit_lowest_rainfall_rates); 


% Remove Timestamps in the data with NaN values
wind_droplet_table.wind_avg(isnan(wind_droplet_table.wind_avg)) = 0;



data_quantity_days = (size(wind_droplet_table,1) * config.DT)/(60*24); % From the number of elements in the table, gives number of days - used for damage calculations



if config.use_best_distribution_simulation
    col_names = "dsd_" + string(0:21);
    n_droplets_air = wind_droplet_table{:, col_names};
else

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

if  config.consider_terminal_velocities & config.use_measured_terminal_velocites
    t_v_calculators = (terminal_v_bins(1:end-1) +terminal_v_bins(2:end))./2; % Currently Gets the midpoint of each of the terminal velocities
    [svd_diameters,svd_vels] = meshgrid(d_calc,t_v_calculators); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point
    svd = svd./(svd_vels); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later - see Incident_Droplet_Calculations.pdf for an explanation)
end
n_droplets_air = sum(svd,1)./(config.DT*60); % Sum across all droplet terminal velocities
n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

A = 0.00456; % area in m^2 of sensor
n_droplets_air = n_droplets_air./A;

if config.consider_terminal_velocities & ~config.use_measured_terminal_velocites
     % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
    t_v_from_diameters = Terminal_V_From_D(d_calc);
    n_droplets_air = n_droplets_air./t_v_from_diameters;
end
end

% --------------------------
% Load in time series wind data:
% --------------------------
wind_velocities = wind_droplet_table{:,"wind_avg"};

if ~ config.use_exact_w_s
     [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
     [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
     wind_velocities = w_calc(indices)';
end
end