clear
clc
close all
% Main Simulation


[w_bins,d_bins,w_mid,d_mid,initialFDF] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat"); % Gets the joint Frequency Distribution Function
v_mid = WindToBladeVelocity(w_mid,57.5);% Converts the wind speed to tip speed for use in the simulation

[d_grid,v_grid] = meshgrid(d_mid,v_mid);


computed_vals = GetSpringerStrength();

allowed_impingements = CalculateAllowedImpingements(computed_vals,v_grid,d_grid);

% Number of impacts on blade:

droplet_terminal_velocity = 1;

FDF = initialFDF .* (v_grid./droplet_terminal_velocity);



% Calculate Damage

damage_grid = FDF ./allowed_impingements;

SpeedDropletPlot(d_bins,log10(FDF),"Incident Droplets");

SpeedDropletPlot(d_bins,log10(initialFDF),"Incident Droplets");



SpeedDropletPlot(d_bins,(damage_grid ./ initialFDF ) ,"Erosibility");

SpeedDropletPlot(d_bins,damage_grid,"Damage Caused");
hold on;
clim([0 0.05])
hold off;
SpeedDropletPlot(d_bins,d_grid,"d\_grid");

SpeedDropletPlot(d_bins,v_grid,"v\_grid");

total_damage = sum(damage_grid,"all");
disp(['The total damage caused to the turbine is: ', num2str(total_damage)])
Hours  = (1/total_damage)*365.24*24;
disp(['Number of Hours ', num2str(Hours)])



%




