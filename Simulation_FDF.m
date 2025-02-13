clear
clc
close all
% Main Simulation


% The following are data imports:
%weibull_params = load("weibull_metmast.mat");
%rainfall = load("annual_rainfall_RENER.mat");

%[w_bins,d_bins,w_mid,d_mid,matrix] = LoadStatisticalDSD({weibull_params.k,weibull_params.c},rainfall.TB_rain);% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value
[w_bins,d_bins,w_mid,d_mid,matrix] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
v_mid = WindToVelocity(w_mid,'Simulation_Data\RENER2024\wind_omega_5MW.mat',63);% Converts the wind speed to tip speed for use in the simulation
[d_grid,v_grid] = meshgrid(d_mid,v_mid);

allowed_impingements = CalculateAllowedImp(v_grid,d_grid);

% Number of impacts on blade:

matrix = matrix .* v_grid;


% Consider impingement efficency

consider_impingement_efficency = true;

if consider_impingement_efficency
    matrix = matrix .* (1 - exp(-15*d_grid));
end

% Calculate Damage

damage_grid = matrix ./allowed_impingements;




SpeedDropletPlot(w_bins,d_bins,log10(matrix'),"Incident Droplets");
SpeedDropletPlot(w_bins,d_bins,log10(allowed_impingements'),"Allowed Impingements");
SpeedDropletPlot(w_bins,d_bins,damage_grid',"Damage Caused");

tot_damage = sum(damage_grid,"all");
disp(['The total damage caused to the turbine is: ', num2str(tot_damage)])
Hours  = (1/tot_damage)*365.24*24;
disp(['Number of Hours ', num2str(Hours)])



%




