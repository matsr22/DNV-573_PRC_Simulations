
clear
clc
close all

% Load in time series data:
DT = 30; % Time step of the data expressed in minutes
structure = struct2cell(load(append("Simulation_Data\Time_Series\data",string(DT),"min_filt.mat")));

timeData = structure{1};
d_bins = structure{2};
w_bins = structure{3};
for x = 1:440
    svdIndexing(x) = append("svd_",string(x-1));
end

svd = timeData{:,svdIndexing};
svdSize = size(svd);
svd = reshape(svd', 20, 22, svdSize(1));  

Dm = [0.1875, 0.3125, 0.4375, 0.625, 0.875, 1.125, 1.375, 1.625,1.875, 2.25, 2.75, 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25, 6.75,7.25, 7.75, 9];
w_bins = [0,w_bins]; % Correction as the current bins are not correct
Wm = [((w_bins(1:end-1)+w_bins(2:end))/2) 11];



Vm = WindToVelocity(Wm,'Simulation_Data\RENER2024\wind_omega_5MW.mat',63);% Converts the wind speed to tip speed for use in the simulation

A = 0.0046; % area in m^2
t_vals = 1:svdSize(1);
[d_grid,v_grid,t_grid] = meshgrid(Dm,Vm,t_vals);
size(d_grid)
size(svd)
v3 = 9.65-10.3*exp(-0.6*d_grid);% Atlas e Ulbrich, 1973 (fit to the data
svd = svd./(A.*(DT*60).*v3);

allowed_impingements = CalculateAllowedImp(v_grid,d_grid);



% Number of impacts on blade:

svd = svd .* v_grid;


% Consider impingement efficency

consider_impingement_efficency = true;

if consider_impingement_efficency
    svd = svd .* (1 - exp(-15*d_grid));
end

% Calculate Damage

damage_grids = svd ./allowed_impingements;

damage_series = sum(damage_grids,[1 2]);
damage_series = permute(damage_series,[2,3,1]);

damage_cumsum = cumsum(damage_series);

tot_damage = sum(damage_series);

plot(damage_cumsum)

Hours  = (1/tot_damage)*365.24*24

