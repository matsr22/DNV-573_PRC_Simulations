clear
clc
close all
% Main Simulation


% The following are data imports:
%weibull_params = load("weibull_metmast.mat");
%rainfall = load("annual_rainfall_RENER.mat");

%[w_bins,d_bins,w_mid,d_mid,FDF] = LoadStatisticalDSD({weibull_params.k,weibull_params.c},rainfall.TB_rain);% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value
[w_bins,d_bins,w_mid,d_mid,initialFDF] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
v_mid = WindToVelocity(w_mid,'Simulation_Data\RENER2024\wind_omega_5MW.mat',63);% Converts the wind speed to tip speed for use in the simulation

[d_grid,v_grid] = meshgrid(d_mid,v_mid);


computed_vals = ComputeSpringerRaw();

allowed_impingements = CalculateAllowedImp(computed_vals,v_grid,d_grid);

% Number of impacts on blade:

droplet_terminal_velocity = 1;

FDF = initialFDF .* (v_grid./droplet_terminal_velocity);


% Consider impingement efficency

consider_impingement_efficency = true;

if consider_impingement_efficency
    FDF = FDF .* (1 - exp(-15*d_grid));
end

% Calculate Damage

damage_grid = FDF ./allowed_impingements;

SpeedDropletPlot(d_bins,log10(FDF),"Incident Droplets");
SpeedDropletPlot(d_bins,log10(initialFDF),"Incident Droplets");
SpeedDropletPlot(d_bins,(damage_grid ./ initialFDF ) ,"Erosibility");
SpeedDropletPlot(d_bins,damage_grid,"Damage Caused");

SpeedDropletPlot(d_bins,d_grid,"d_grid");

SpeedDropletPlot(d_bins,v_grid,"v_grid");

tot_damage = sum(damage_grid,"all");
disp(['The total damage caused to the turbine is: ', num2str(tot_damage)])
Hours  = (1/tot_damage)*365.24*24;
disp(['Number of Hours ', num2str(Hours)])



%




