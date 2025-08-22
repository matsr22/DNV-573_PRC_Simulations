% Creates a file that has rain data at a certain temporal resolution and
% wind data at the original 10 minute resolution


DT_original = 10; % Data source file resolution
DT_final = 60; % Target rain temporal resolution of final file

root_path = "C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\";
original_data_source = "Lancaster\10min_data_filt.mat";
final_data_save_name = "Lancaster_"+string(DT_final)+"\10min_data_filt.mat";

average_interval_size = DT_final / DT_original;

original_data = load(root_path+original_data_source);

temp = struct2cell(original_data);
modified_table = temp{1};

d_bins = [temp{2} 10];
d_calc = (d_bins(1:end-1) + d_bins(2:end))./2;


% Loop through sets of records to average

table_height = length(modified_table.dateTime);



for start_interval = 1:average_interval_size:table_height
    chunk_index = start_interval:min(start_interval+average_interval_size-1, table_height);
    
    svd_index = "svd_" + string(0:439);  % vector of names
    old_svd = modified_table{chunk_index,svd_index};
    averaged_svd = mean(old_svd,1);
    new_svd = repmat(averaged_svd,length(chunk_index),1);
    modified_table{chunk_index,svd_index} = new_svd;

    dsd_index = "dsd_" + string(0:21);  % vector of names
    old_dsd = modified_table{chunk_index,dsd_index};
    averaged_dsd = mean(old_dsd,1);
    new_dsd = repmat(averaged_dsd,length(chunk_index),1);
    modified_table{chunk_index,dsd_index} = new_dsd;

    dvd_index = "dvd_" + string(0:19);  % vector of names
    old_dvd = modified_table{chunk_index,dvd_index};
    averaged_dvd = mean(old_dvd,1);
    new_dvd = repmat(averaged_dvd,length(chunk_index),1);
    modified_table{chunk_index,dvd_index} = new_dvd;


    old_rainfalls = modified_table{chunk_index,'rainfall'};
    averaged_rainfalls = mean(old_rainfalls,1);
    new_rainfalls = repmat(averaged_rainfalls,length(chunk_index),1);
    modified_table{chunk_index,'rainfall'} = new_rainfalls;

    old_rainfalls = modified_table{chunk_index,'precipitation_flux'};
    averaged_rainfalls = mean(old_rainfalls,1);
    new_rainfalls = repmat(averaged_rainfalls,length(chunk_index),1);
    modified_table{chunk_index,'precipitation_flux'} = new_rainfalls;




end


field_names = string(fieldnames(original_data)); 

saving_struct.(field_names(1)) = modified_table;
saving_struct.(field_names(2)) = temp{2};
saving_struct.(field_names(3)) = temp{3};

save(root_path+final_data_save_name,'-struct',"saving_struct");

