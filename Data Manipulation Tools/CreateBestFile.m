% Creates a File in which the Best distribution for the rainfall is
% allready calculated in order to reduce computation time elsewhere. This
% is in the form of a dsd in /m^3 form 

clc;
clear all;

DT = 10;

root_path = "C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\";
original_data_source = "North_Sea\10min_data_best.mat";
final_data_save_name = "North_Sea\10min_data_best.mat";

original_data = load(root_path+original_data_source);

temp = struct2cell(original_data);
modified_table = temp{1};

d_bins = [temp{2} 10];
d_calc = (d_bins(1:end-1) + d_bins(2:end))./2;


volumes = (4/3)*pi* (d_calc./2).^3;

for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end


A = 0.00456;
format shortG

% Gets the collumns of the dsd from the table
droplets_measured = modified_table{:,dsd_indexing};


rainfalls = modified_table.rainfall_rate;
rainfalls(isnan(rainfalls)) = 0;
n_droplets_air = ConstructBestDistributions(rainfalls,d_calc,d_bins); % Constructs from the rainfall at each timestep an equivilent Best DSD - directly obtains drops per cubic meter
% 
% colsToRemove = "svd_" + string(0:439);  % vector of names
% modified_table = removevars(modified_table, colsToRemove);
% 
% 
% colsToRemove = "dvd_" + string(0:19);  % vector of names
% modified_table = removevars(modified_table, colsToRemove);

for x = 1:22
    col_name = append("dsd_",string(x-1));
    modified_table.(col_name) = n_droplets_air(:,x);
end
%%
field_names = string(fieldnames(original_data)); 

saving_struct.(field_names(1)) = modified_table;
saving_struct.(field_names(2)) = temp{2};
saving_struct.(field_names(3)) = temp{3};

save(root_path+final_data_save_name,'-struct',"saving_struct");

