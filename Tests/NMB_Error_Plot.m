clear;
clc;
close all;

addpath("..");
% Gives total rainfall for each location from measured value

DT = 1; % Controls what time resolution is used for the simulation

location_considered = "Lancaster";


structure_filt = struct2cell(load(append("..\Simulation_Data\",location_considered,"\",num2str(DT),"min_data_filt.mat")));
structure_best = struct2cell(load(append("..\Simulation_Data\",location_considered,"\",num2str(DT),"min_data_best.mat")));% Using the non-filtered data to match the joint FDF



% Gets the droplet diameters as reported in the files (starting at 0.125)
d_lowers = structure_filt{2};

% This is the midpoint of the droplet diameter bins
d_uppers = [d_lowers(2:end) 10]; % Arbitarily choses 9mm as the upper value of the largest droplet bin. This value should not make much difference as not many droplets in this bin
d_mids = (d_lowers+ d_uppers)./2;

d_bins = [d_lowers 10];

d_widths = d_bins(2:end)-d_bins(1:end-1);

d_calc = d_mids;

%%
volumes = (4/3)*pi* (d_calc./2).^3;


% Gets the rainfall data directly from the table and sums 
data_table = structure_filt{1};
best_table = structure_best{1};

for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end


A = 0.00456;
format shortG

% Gets the collumns of the dsd from the table
droplets_measured = data_table{:,dsd_indexing};

rainfalls_measured = sum(volumes.*droplets_measured./(A*1e6),2)/(DT/60); 


col_names = "dsd_" + string(0:21);
droplets_per_cubic_best = best_table{:, col_names};

 % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
t_v_from_diameters = Terminal_V_From_D(d_calc);



% Convert to rainfall  in mm - multiply number of droplets by the volume of
% each to get total rain volume in mm^3 then divide by area of disdrometer

droplets_per_cubic_measured = ((droplets_measured./A)./t_v_from_diameters)/(DT*60);

%% Rainfall Calculations

NMB_type = 1; % Set 1 for an NMB for each droplet class and 2 for an NMB for each sampling point 


rainfalls_best = sum(volumes.*((droplets_per_cubic_best./Terminal_V_From_D(d_calc))),2)/(DT/60);



rainfall_bins =  [0.1 1 3 5 10 20 inf];

rainfalls_table = rainfalls_measured;


indexes = {2:5,6:11,12:22};

num_data_series = length(indexes);
data_series = zeros(num_data_series,length(rainfall_bins)-1);
std_series = zeros(num_data_series,length(rainfall_bins)-1);

for x = 1:num_data_series
    idx = indexes{x};
    for i = 1:(length(rainfall_bins)-1)
        data_best = droplets_per_cubic_best(:,idx);

        data_best = data_best(rainfalls_table>=rainfall_bins(i) & rainfalls_table<rainfall_bins(i+1),:);
        
        data_best = data_best./d_widths(idx);
        data_measured = droplets_per_cubic_measured(:,idx);
        data_measured = data_measured(rainfalls_table>=rainfall_bins(i) & rainfalls_table<rainfall_bins(i+1),:);
        
        data_measured = data_measured./d_widths(idx);
        NMBs = sum(data_best-data_measured,NMB_type) ./ sum(data_measured,NMB_type);

        NMBs = NMBs(~isnan(NMBs) & ~isinf(NMBs));

        data_series(x,i) = mean(NMBs);


        std_series(x,i) = std(NMBs);

    end
end





x_labels = {'0.1-1 mm h^{-1}', '1-3 mm h^{-1}', '3-5 mm h^{-1}', ...
            '5-10 mm h^{-1}', '10-20 mm h^{-1}', '>20 mm h^{-1}'};
x = 1:length(x_labels);

figure('Position',[403 121 820 505]);
hold on;


errorbar(x, data_series(1,:), std_series(1,:), 'r', 'LineWidth', 1.5, 'DisplayName', 'small D');
errorbar(x, data_series(2,:), std_series(2,:), 'k', 'LineWidth', 1.5, 'DisplayName', 'medium D');
errorbar(x, data_series(3,:), std_series(3,:), 'b', 'LineWidth', 1.5, 'DisplayName', 'large D');

yline(0, '--', 'Color', [0.5 0.5 0.5],'HandleVisibility', 'off');

xticks(x);
xticklabels(x_labels);
xtickangle(45);
ylabel('NMB');
xlabel('Rainfall')
legend('Location', 'northeast');
ylim([-2 2]);

xlim('padded');

lowest_drop_class = indexes{1};
if lowest_drop_class(1) == 1
    omission= " No Omission";
else
    omission = " First DSD Ommited";
end

if NMB_type == 1
    graph_name = location_considered + " - NMB per droplet class -"+ omission;
else
    graph_name = location_considered + " - NMB per sampling poin -"+ omission;
end
box on;
grid on;
Save_Fig_Validated(graph_name)

close gcf;






% Function to remove the patched data in the table - unuses atm

