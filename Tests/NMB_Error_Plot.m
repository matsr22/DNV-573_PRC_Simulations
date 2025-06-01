clear;
clc;
close all;

addpath("..");
% Gives total rainfall for each location from measured value

DT = 10; % Controls what time resolution is used for the simulation

location_considered = "Lancaster";


structure_filt = struct2cell(load(append("..\Simulation_Data\",location_considered,"\",num2str(DT),"min_data_filt.mat")));% Using the non-filtered data to match the joint FDF

% Gets the droplet diameters as reported in the files (starting at 0.125)
d_lowers = structure_filt{2};

% This is the midpoint of the droplet diameter bins
d_uppers = [d_lowers(2:end) 10]; % Arbitarily choses 9mm as the upper value of the largest droplet bin. This value should not make much difference as not many droplets in this bin
d_mids = (d_lowers+ d_uppers)./2;

d_bins = [d_lowers 10];

d_calc = d_mids;

volumes = (4/3)*pi* (d_calc./2).^3;


% Gets the rainfall data directly from the table and sums 
data_table = structure_filt{1};

for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end



% Gets the collumns of the dsd from the table
droplets_measured = data_table{:,dsd_indexing};

droplets_per_cubic_best = ConstructBestDistributions(data_table,d_calc,d_bins);

v_parametric = @(d) 9.65 - 10.3.*exp(-0.6.*d); % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
t_v_from_diameters = v_parametric(d_calc);

A = 0.0046;
format shortG


% Convert to rainfall  in mm - multiply number of droplets by the volume of
% each to get total rain volume in mm^3 then divide by area of disdrometer

droplets_per_cubic_measured = ((droplets_measured./A)./t_v_from_diameters)/(DT*60);

%% Rainfall Calculations




rainfalls_best = sum(volumes.*((droplets_per_cubic_best./v_parametric(d_calc))),2)/(DT/60);

rainfalls_measured = sum(volumes.*droplets_measured./(A*1e6),2)/(DT/60); 

rainfall_bins =  [0 1 3 5 10 20 50 inf];

rainfalls_table = rainfalls_best;


indexes = {1:5,6:11,12:22};
data_series = zeros(3,7);
std_series = zeros(3,7);

for x = 1:3
    idx = indexes{x};
    for i = 1:(length(rainfall_bins)-1)
        data_best = droplets_per_cubic_best(:,idx);
        data_best = data_best(rainfalls_table>=rainfall_bins(i) & rainfalls_table<rainfall_bins(i+1),:);

        data_measured = droplets_per_cubic_measured(:,idx);
        data_measured = data_measured(rainfalls_table>=rainfall_bins(i) & rainfalls_table<rainfall_bins(i+1),:);
        
        NMBs = sum(data_best - data_measured,1) ./ sum(data_measured,1);

        NMBs = NMBs(~isnan(NMBs) & ~isinf(NMBs));

        data_series(x,i) = mean(NMBs,"all");


        std_series(x,i) = std(NMBs);

    end
end





x_labels = {'0-1 mm h^{-1}', '1-3 mm h^{-1}', '3-5 mm h^{-1}', ...
            '5-10 mm h^{-1}', '10-20 mm h^{-1}', '20-50 mm h^{-1}', '>50 mm h^{-1}'};
x = 1:length(x_labels);

figure;
hold on;

errorbar(x, data_series(1,:), std_series(1,:), 'g', 'LineWidth', 1.5, 'DisplayName', 'small D');
errorbar(x, data_series(2,:), std_series(2,:), 'k', 'LineWidth', 1.5, 'DisplayName', 'medium D');
errorbar(x, data_series(3,:), std_series(3,:), 'b', 'LineWidth', 1.5, 'DisplayName', 'large D');

yline(0, '--', 'Color', [0.5 0.5 0.5],'HandleVisibility', 'off');

xticks(x);
xticklabels(x_labels);
xtickangle(45);
ylabel('NMB');
legend('Location', 'northeast');
ylim([-10 15]);
box on;
grid on;




% Function to remove the patched data in the table - unuses atm

