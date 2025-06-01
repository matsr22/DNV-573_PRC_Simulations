
close all;
clear all;
addpath('..'); % Ensures functions from parent folder can be used in this folder

DT = 10; % Specifies temporal resolution of data used

location_considered = "Lampedusa";

imported_structure = struct2cell(load(append("..\Simulation_Data\",location_considered,"\",string(DT),"min_data_filt.mat")));

imported_data = imported_structure{1};

d_bins = [imported_structure{2} 10]; % The bins are provided by the definition by Elisa, both lower and upper defined

d_calc = (d_bins(1:end-1) + d_bins(2:end))./2; 

% Construct the Best Distribution

n_droplets_air = ConstructBestDistributions(imported_data,d_calc,d_bins);

sum_droplets_dsd_best = sum(n_droplets_air,1)';

% Construct the Measured Distribution

for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end

% Gets the collumns of the joint SVD from the table
svd = imported_data{:,svd_indexing};
svdSize = size(svd);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd = reshape(svd', 20, 22, svdSize(1));  

sum_droplets_dsd_measured = sum(svd,[1,3]);

A = 0.00456; % area in m^2 of sensor
sum_droplets_dsd_measured = sum_droplets_dsd_measured./A;
v_parametric = @(d) 9.65 - 10.3.*exp(-0.6.*d); % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
t_v_from_diameters = v_parametric(d_calc);
sum_droplets_dsd_measured = sum_droplets_dsd_measured./t_v_from_diameters;

sum_droplets_dsd_measured = (sum_droplets_dsd_measured ./ (DT*60))';

plot(d_calc, sum_droplets_dsd_best, '-ko', 'MarkerFaceColor', 'k'); % Plot the Best Results
hold on;
plot(d_calc,sum_droplets_dsd_measured , '--ro', 'MarkerFaceColor', 'r'); % Plot the Measured Results 

best_total = sum(sum_droplets_dsd_best)
measured_total = sum(sum_droplets_dsd_measured)
legend('Best DSD', 'Measured DSD');
grid on;

ax = gca; 
ax.YMinorGrid = 'off';
ax.XMinorGrid = 'off';

ax.YMinorTick = 'off';
ax.XMinorTick = 'off';

xlabel('Droplet Diameter (mm)');
ylabel('Damage (Years^{-1})');