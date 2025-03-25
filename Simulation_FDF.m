
clear;
clc;
close all;

% Simulation Performed on the Frequency Distribution Matrix 

%
% Configuration of the simulation 
%

strip_radii = [45.15 49.25 53 56.05 58.75 60.8]; % Strips, indexed 1 to 6 of those considered in the paper

strip_index = 6; % Strip to consider if only considering 1

consider_all_strips = false;
plot_graphs = true;

if consider_all_strips
    num_loops = 1:length(strip_radii);
else
    num_loops = strip_index;
end


% Gets the joint Frequency Distribution Function and the wind and droplet
% values used for calculations for each bin (configurable in the LoadMeasuredDSD function)
[w_calc,d_calc,initialFDF] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat"); 

for i = 1:length(strip_radii) % Loops over each strip

v_calc = WindToBladeVelocity(w_calc,strip_radii(i));% Converts the wind speed to tip speed for use in the simulation

[d_grid,v_grid] = meshgrid(d_calc,v_calc);



computed_vals = GetSpringerStrength(); % Sets up the modified springer constants

allowed_impingements = CalculateAllowedImpingements(computed_vals,v_grid,d_grid);

% Number of impacts on blade:

droplet_terminal_velocity = 1;

FDF = initialFDF .* (v_grid./droplet_terminal_velocity); % Equation 



% Calculate Damage

damage_grid = FDF ./allowed_impingements;
total_damage = sum(damage_grid,"all");

strip_hours(i) = (1/total_damage)*356*24;
strip_damage(i) = total_damage;
end

format longG
strip_hours = round(strip_hours);

ref_lifetimes = [30502 18597 12210 8846 6739 5524]; % Lifetimes given by ROME for the non-turbulent analysis


if plot_graphs
    d_bins = [d_calc 10];
    
    SpeedDropletPlot(d_bins,log10(FDF),"Incident Droplets per m^2 (Upon Blade)");
    
    SpeedDropletPlot(d_bins,log10(initialFDF),"Incident Droplets per m^2  (Air)");
    
    SpeedDropletPlot(d_bins,damage_grid,"n/N - Joint FDF");
    hold on;
    clim([0 0.05]) % To match the damage scale used in the paper - for comparison
    hold off;
end

disp('Incubation Time Predicted:')

ans =strip_hours(strip_index)

disp('Percentage difference between predicted and reference:')

100*(abs(strip_hours(strip_index)-ref_lifetimes(strip_index))./ref_lifetimes(strip_index))


