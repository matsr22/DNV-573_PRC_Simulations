

%
% Configuration of the Simulation
%
% ---------------------------
% Analysis - DATASET USED
% ---------------------------
location_considered = "Lancaster"; % Determines which location is being analysed, options: [Lancaster], [Lecce], [Lampedusa]
DT = 10; % Temporal Resolution of the Data, expressed in minutes
% ---------------------------
% Analysis - TURBINE OPTIONS
% ---------------------------
turbine_used = "15MW";% Gives which turbine is considered by the analysis options: [3MW] WINDPACT Turbine, [5MW] NREL Turbine and [15MW] NREL Turbine
coating_used = 'AAP'; % Alters the coating properties used in the analysis, options: [AAP] (from the RENER2024 paper), [ThreeM] (Case 2 in Sanchez Et al), [ORE] (Case 3 in Sanchez Et al)
consider_all_strips = false; % Controls if all strips are calculated or just the outermost one
% ---------------------------
% Analysis - RAINFALL OPTIONS
% ---------------------------
use_filtered_data = true;
consider_terminal_velocities = true; % If false sets all terminal velocities to 1, as is done in the joint FDF
use_measured_terminal_velocites = false; % If considering terminal velocities, use measured rather than emperical
use_best_distribution = false;

% ---------------------------
% Analysis - WIND OPTIONS
% ---------------------------
use_extrapolated_wind_data = true;
use_exact_w_s = true; % Controls if the exact wind speed is used or      the wind is placed into bins and then the average of that bin is used

% ---------------------------
% Analysis - PLOTTING OPTIONS
% ---------------------------
plot_fdf = true; % Controls if the simulation is plotted or if just damage values are shown
fdf_plotting_variables = ["Droplet_Diameter","Mass_Weighted_Diameter","Rainfall","Drops_Air"];
fdf_variable_chosen = 4;

strip_radii = load(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Turbine_Curves\Turbine_Data_",turbine_used,".mat"),"radii"); % Strips, indexed 1 to 6 of those considered in the paper
strip_radii = strip_radii.radii;

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

% Modifies the file accessed to be that specific to the extrapolation
% required of each turbine. 5MW not added as this is not yet relevant to
% analysis we are doing. 
if use_extrapolated_wind_data
    if turbine_used == "3MW"
        suffix = append(suffix,"_119_ext");
    elseif turbine_used == "15MW"
        suffix = append(suffix,"_150_ext");
    end
end
%
% Import Data
%

imported_structure = struct2cell(load(append("Simulation_Data\",location_considered,"\",string(DT),"min_data_",suffix,".mat"))); 

% Remove Timestamps in the data with NaN values

wind_droplet_table = imported_structure{1};


wind_droplet_table = wind_droplet_table(~isnan(wind_droplet_table.("wind_avg")), :);

data_quantity_days = (size(wind_droplet_table,1) * DT)/(60*24);

% --------------------------
% Load in time series rain data:
% --------------------------
d_bins = [imported_structure{2} 10]; % The bins are provided by the definition by Elisa, both lower and upper defined
terminal_v_bins = [0 imported_structure{3} 20]; % The bins are provided for both upper and lower by Elisa 

% Generates a vector of the variables of the joint size velocity
% distribution indexes
for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end

% The diameters and velocities assosiated with each of the bins in svd 
% Use the midpoint for both
d_calc = (d_bins(1:end-1) + d_bins(2:end))./2; 

for i = strip_index

if use_best_distribution
    rainfalls = wind_droplet_table.rainfall_mm_hr; % Gives the rainfall in mm/hr for each interval

    efficency_threshold = 1e-5; %Sets the threshold at which below this, calculating the integral is ignored to save computation power without affecting the result
    
    W = @(R) 67*R.^0.846; % Rainfall is input in mm_hr in this context
    V = @(D) (1/6)*pi*(D.^3);
    a = @(R) 1.3*R.^0.232;
    k_B = 2.25;
    best_distribution = @(D,R) (W(R)./V(D)) .* ((k_B*D.^(k_B-1))./(a(R).^k_B)).*exp(-(D./a(R)).^k_B);
    n_droplets_air = zeros(length(rainfalls),length(d_calc));
    for x = 1:length(rainfalls)
        best_set_rainfall = @(D) best_distribution(D,rainfalls(x));
        if rainfalls(x) == 0
            n_droplets_air(x,:) = 0;
        else
            
            for u = 1:length(d_calc)
                integral_estimator = best_set_rainfall(d_calc(u))*(d_bins(u+1)- d_bins(u+1));
                if(integral_estimator < efficency_threshold)
                    n_droplets_air(x,u) = integral(best_set_rainfall,d_bins(u),d_bins(u+1));
                else
                    n_droplets_air(x,u) = 0;
                end
            end   
        end
    end
else
% Gets the collumns of the joint SVD from the table
svd = wind_droplet_table{:,svd_indexing};
svdSize = size(svd);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd = reshape(svd', 20, 22, svdSize(1));  

if  consider_terminal_velocities & use_measured_terminal_velocites
    t_v_calculations = (terminal_v_bins(1:end-1) +terminal_v_bins(2:end))./2; % Currently Gets the midpoint of each of the terminal velocities
    [svd_diameters,svd_vels] = meshgrid(d_calc,t_v_calculations); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point
    svd = svd./(svd_vels); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later - see Incident_Droplet_Calculations.pdf for an explanation)
end
n_droplets_air = sum(svd,1)./(DT*60); % Sum across all droplet terminal velocities
n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

A = 0.00456; % area in m^2 of sensor
n_droplets_air = n_droplets_air./A;

if consider_terminal_velocities & ~use_measured_terminal_velocites
    v_parametric = @(d) 9.65 - 10.3.*exp(-0.6.*d); % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
    t_v_from_diameters = v_parametric(d_calc);
    n_droplets_air = n_droplets_air./t_v_from_diameters;
end
end

% --------------------------
% Load in time series wind data:
% --------------------------
wind_velocities = wind_droplet_table{:,"wind_avg"};

if ~ use_exact_w_s
     [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
     [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
     wind_velocities = w_calc(indices)';
end

% Convert the wind speeds to the corresponding speed of the blade at a
% each index

if 

blade_velocities = WindToBladeVelocity(wind_velocities,strip_radii(i),turbine_used);









% Create matrix of number of droplets incident on blade per m^2
n_s = n_droplets_air .* impact_velocities.*(DT*60); % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)

% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.
[diameter_mesh,blade_vel_mesh] = meshgrid(d_calc,impact_velocities); 


computed_vals = GetSpringerStrength(coating_used); % Sets up the springer strength (Given in the RENER paper) - Ideally move this and other similar preparation steps outside the loop

allowed_impingements = CalculateAllowedImpingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination

damages = n_s./allowed_impingements; 

time_series_damage = sum(damages,2); % Gets the damage for every timestep


droplet_diameter_damage = sum(damages,1); % Gets the damage for each droplet diameter

total_damage = sum(damages,'all');
strip_damage(i) = total_damage;
strip_hours(i) = (1/total_damage)*data_quantity_days*24; % This was one of the differences between the Rome research team's results and mine, I am using the correct slightly modified number of days in the dataset, they were using number of days in a year

end

Plotting_Algorithms(plot_fdf,use_exact_w_s,wind_velocities,fdf_variable_chosen,damages,d_bins,n_s,n_droplets_air);

total_drops_air_2 = sum((n_droplets_air*DT*60)/(data_quantity_days*60*60*24*365),1);


disp('Incubation Time Predicted:')

disp(strip_hours(strip_index))








