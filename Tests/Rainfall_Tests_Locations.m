clear;
clc;
close all;


% Gives total rainfall for each location from measured value


d_position = 2; % Controls if the lower end of the bin - The droplet diameters provided by the data (1), the midpoint of the bin (2) or the upper end of the bin (3) is used in droplet calculations

DT = 10; % Controls what time resolution is used for the simulation


lampedusa_structure_filt = struct2cell(load(append("..\Simulation_Data\Lampedusa\",num2str(DT),"min_data_filt_150_ext.mat")));% Using the non-filtered data to match the joint FDF
lancaster_structure_filt = struct2cell(load(append("..\Simulation_Data\Lancaster\",num2str(DT),"min_data_filt.mat")));% Using the non-filtered data to match the joint FDF

% Gets the droplet diameters as reported in the files (starting at 0.125)
d_lowers = lampedusa_structure_filt{2};

% This is the midpoint of the droplet diameter bins
d_uppers = [d_lowers(2:end) 10]; % Arbitarily choses 9mm as the upper value of the largest droplet bin. This value should not make much difference as not many droplets in this bin
d_mids = (d_lowers(1:end)+ d_uppers)./2;


if d_position == 1
    d_calc = d_lowers;
elseif d_position == 2
    d_calc = d_mids;
elseif d_position == 3
    d_calc = d_uppers;
end
volumes = (4/3)*pi* (d_calc./2).^3;


% Gets the rainfall data directly from the table and sums 
lampedusa_table = lampedusa_structure_filt{1};
lancaster_table = lancaster_structure_filt{1};

for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end



% Gets the collumns of the dsd from the table
lampedusa_droplets = lampedusa_table{:,dsd_indexing};

lancaster_droplets = lancaster_table{:,dsd_indexing};




A = 0.0046*1000*1000;
format shortG


% Convert to rainfall  in mm - multiply number of droplets by the volume of
% each to get total rain volume in mm^3 then divide by area of disdrometer
droplet_volumes_lampedusa = volumes.*lampedusa_droplets./A; 

droplet_volumes_lancaster = volumes.*lancaster_droplets./A;


% Sum across timesteps and droplet diameters
rainfall_lampedusa = sum(droplet_volumes_lampedusa,"all")
rainfall_lancaster = sum(droplet_volumes_lancaster,"all")





% Function to remove the patched data in the table - unuses atm

