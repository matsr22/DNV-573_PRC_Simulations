clear
clc
close all
% Main Simulation


[w_bins,d_bins,w_mid,d_mid,initialFDF] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat"); % Gets the joint Frequency Distribution Function

strip_radius = 60.8; % Gives the radius of the strip being considered 60.8 corresponds to strip 6 in the paper
v_mid = WindToBladeVelocity(w_mid,strip_radius);% Converts the wind speed to tip speed for use in the simulation

[d_grid,v_grid] = meshgrid(d_mid,v_mid);


computed_vals = GetSpringerStrength();

allowed_impingements = CalculateAllowedImpingements(computed_vals,v_grid,d_grid);

% Number of impacts on blade:

droplet_terminal_velocity = 1;

FDF = initialFDF .* (v_grid./droplet_terminal_velocity);



% Calculate Damage

damage_grid = FDF ./allowed_impingements;

SpeedDropletPlot(d_bins,log10(FDF),"Incident Droplets per m^2 (Upon Blade)");

SpeedDropletPlot(d_bins,log10(initialFDF),"Incident Droplets per m^2 (Air)");

SpeedDropletPlot(d_bins,damage_grid,"Damage Caused");
hold on;
clim([0 0.05]) % To match the damage scale used in the paper - for comparison
hold off;

total_damage = sum(damage_grid,"all");
disp(['The total damage caused to the turbine is: ', num2str(total_damage)])
Hours  = (1/total_damage)*356*24;
disp(['Number of Hours for Incubation ', num2str(Hours)])


