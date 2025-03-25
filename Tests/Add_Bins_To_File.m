% Adds the terminal velocity and droplet size bins to the data

DT = 10;
Folder1 = "..\Simulation_Data\Lecce\";
Folder2 = "_2024";

dataset = (load(append(Folder1,"Lecce_filt_",string(DT),"min_data.mat")));
% dataset2 = load(append("..\Simulation_Data\Time_Series_Lancaster\10min_data_filt.mat"));
% 
% fields_to_copy = fieldnames(dataset2);
% fields_to_copy = fields_to_copy(2:end);
% 
% for i = 1:length(fields_to_copy)
%     field_name = fields_to_copy{i};
%     dataset.(field_name) = dataset2.(field_name);
% end

save(append(Folder1,string(DT),"min_data_filt.mat"),"-struct","dataset");

