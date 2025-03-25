
close all


%
% Configuration of the Simulation
%

turbine_used = 5;% Gives the power of the turbine to be considered - Currently only works for the 5MW turbine and 15MW
coating_used = "x3M_Case_2";

use_filtered_data = true;
consider_all_strips = false; % Controls if all strips are calculated or just the outer one
consider_terminal_velocities = true; % If false sets all terminal velocities to 1, as is done in the joint FDF
use_measured_terminal_velocites = true; % If considering terminal velocities, use measured rather than emperical
plot_fdf = false; % Controls if the simulation is plotted on fdfs 
use_exact_w_s = true; % Controls if the exact wind speed is used or if the wind is placed into bins and then the average of that bin is used
fdf_plotting_variables = ["Droplet_Diameter","Mass_Weighted_Diameter","Rainfall"];
fdf_variable_chosen = 2;

DT = 10; % Time step of the data expressed in minutes


strip_radii = load(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\RENER2024\Turbine_Data_",string(turbine_used),"MW.mat"),"radii"); % Strips, indexed 1 to 6 of those considered in the paper
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

%
% Import Data
%

imported_structure = struct2cell(load(append("Simulation_Data\Time_Series_Lancaster\",string(DT),"min_data_",suffix,".mat")));% Using the non-filtered data to match the joint FDF


for i = strip_index

% Load in time series data:
wind_droplet_table = imported_structure{1};


d_bins = [imported_structure{2} 10]; % The bins are provided by the definition by Elisa, both lower and upper defined
terminal_v_bins = [0 imported_structure{3} 20]; % The bins are provided for both upper and lower by Elisa 


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
% Use the midpoint for both
d_calc = (d_bins(1:end-1) + d_bins(2:end))./2; 



% Wind speed at each timestep
wind_velocities = wind_droplet_table{:,"wind_avg"};

if ~use_exact_w_s
     [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
     [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
     wind_velocities = w_calc(indices)';
end

% Convert the wind speeds to the corresponding speed of the blade at a
% each index

blade_velocities = WindToBladeVelocity(wind_velocities,strip_radii(i),turbine_used);

impact_velocities = blade_velocities; % This line is included to allow for modification of the impact velocities to include the wind speed

% Create matrix of number of droplets incident on blade per m^2


if  consider_terminal_velocities & use_measured_terminal_velocites
    t_v_calculations = (terminal_v_bins(1:end-1) +terminal_v_bins(2:end))./2; % Currently Gets the midpoint of each of the terminal velocities
    [svd_diameters,svd_vels] = meshgrid(d_calc,t_v_calculations); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point
    svd = svd./(svd_vels); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later - see Incident_Droplet_Calculations.pdf for an explanation)
end
A = 0.00456; % area in m^2 of sensor
svd = svd./A;
n_droplets_air = sum(svd,1); % Sum across all droplet terminal velocities

if consider_terminal_velocities & ~use_measured_terminal_velocites
    v_parametric = @(d) 9.65 - 10.3.*exp(-0.6.*d); % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
    t_v_from_diameters = v_parametric(d_calc);
    n_droplets_air = n_droplets_air./t_v_from_diameters;
end

n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

n_s = n_droplets_air .* impact_velocities; % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)

% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.
[diameter_mesh,blade_vel_mesh] = meshgrid(d_calc,impact_velocities); 


computed_vals = GetSpringerStrength(coating_used); % Sets up the springer strength (Given in the RENER paper) - Ideally move this and other similar preparation steps outside the loop

allowed_impingements = CalculateAllowedImpingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination

damages = n_s./allowed_impingements; 

time_series_damage = sum(damages,2); % Gets the damage for every timestep

droplet_diameter_damage = sum(damages,1); % Gets the damage for each droplet diameter



total_damage = sum(damages,'all');
total_droplets = sum(n_s, 'all')
strip_damage(i) = total_damage;
strip_hours(i) = (1/total_damage)*356*24; % This was one of the differences between the Rome research team's results and mine, I am using the correct slightly modified number of days in the dataset, they were using number of days in a year

end

% Places wind velocity into bins rather than using the exact value - for
% comparison purposes and plotting
if plot_fdf
    % Re-construct FDF:
    if use_exact_w_s % If the calculations in the code are not being simplified, simplify here
        [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
        [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
        wind_velocities = w_calc(indices)';
    end
    if (fdf_variable_chosen == 1)
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
    elseif fdf_variable_chosen == 2
        mass_weighted_d_bins = d_bins; % Inserted so that bins for the plotting of mass weighted diameters can be modified
        mass_weighted_d_mid = (mass_weighted_d_bins(1:end-1)-mass_weighted_d_bins(2:end))./2;
        mass_w_diameters = sum(n_s.*d_calc.^4,2)./sum(n_s.*d_calc.^3,2); % Gets the mass weighted diameter for each

        [~, indices] = min(abs(mass_w_diameters - d_calc), [], 2);
        mass_w_diameters_q = d_calc(indices)';

        damages_FDF =  zeros(length(w_calc),length(d_calc));
        for w= 1:length(w_calc)
            for d =  1:length(d_calc)
                wind = w_calc(w);
                m_w_d = d_calc(d);
                damages_m_w_d(w,d) = sum(damages(wind == wind_velocities & m_w_d == mass_w_diameters_q,:),"all");
            end
        end
        SpeedDropletPlot(d_bins,damages_m_w_d,"n/N - Mass Weighted Diameter")
    elseif fdf_variable_chosen == 3
        rainfall_totals = sum(n_droplets_air.*(4/3).*pi.*(d_calc./2).^3,2);
        rainfall_bins = logspace(log10(5000),log10(max(rainfall_totals)),23);

        rainfall_mids = (rainfall_bins(1:end-1)+rainfall_bins(2:end))./2;

        [~,indices] = min(abs(rainfall_totals-rainfall_mids),[],2);

        rainfall_tot_q = rainfall_mids(indices)';
        for w= 1:length(w_calc)
            for r =  1:length(rainfall_mids)
                wind = w_calc(w);
                rainfall = rainfall_mids(r);
                damages_rainfall(w,r) = sum(damages(wind == wind_velocities & rainfall == rainfall_tot_q,:),"all");
            end
        end
        SpeedDropletPlot(rainfall_bins,damages_rainfall,"n/N - Rainfall")
        hold on;
        ylabel("rainfall [mm]");
        hold off;
    end

    
end

disp('Incubation Time Predicted:')

disp(strip_hours(strip_index))







