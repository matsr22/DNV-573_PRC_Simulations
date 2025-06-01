addpath("..");

DT = 10; % Controls what time resolution is used for the simulation

location_considered_1 = "Lampedusa";
location_considered_2 = "Lancaster"


structure_filt1 = struct2cell(load(append("..\Simulation_Data\",location_considered1,"\",num2str(DT),"min_data_filt.mat")));% Using the non-filtered data to match the joint FDF
structure_filt2 = struct2cell(load(append("..\Simulation_Data\",location_considered2,"\",num2str(DT),"min_data_filt.mat")));% Using the non-filtered data to match the joint FDF

% Gets the droplet diameters as reported in the files (starting at 0.125)
d_lowers = structure_filt{2};

% This is the midpoint of the droplet diameter bins
d_uppers = [d_lowers(2:end) 10]; % Arbitarily choses 9mm as the upper value of the largest droplet bin. This value should not make much difference as not many droplets in this bin
d_mids = (d_lowers(1:end)+ d_uppers)./2;

d_bins = [d_lowers 10];

d_calc = d_mids;


% Gets the rainfall data directly from the table and sums 
data_table1 = structure_filt1{1};
data_table2 = structure_filt2{1};

for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end



% Gets the collumns of the dsd from the table
droplets_measured1 = data_table1{:,dsd_indexing};

rainfalls1 = data_table1.rainfall_mm_hr;

mass_weighted_diameters1 = sum(droplets_measured1.*d_calc.^4,2)./sum(droplets_measured1.*d_calc.^3,2); % Gets the mass weighted diameter for each

droplets_measured2 = data_table1{:,dsd_indexing};

rainfalls2 = data_table2.rainfall_mm_hr;

mass_weighted_diameters2 = sum(droplets_measured2.*d_calc.^4,2)./sum(droplets_measured2.*d_calc.^3,2); % Gets the mass weighted diameter for each


figure;
hold on;

scatter()
rainfall_bins = logspace(0.1,100);