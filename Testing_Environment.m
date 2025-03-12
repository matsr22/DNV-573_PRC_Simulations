% % Testing Environment
% clear
% clc
% close all
% 
% DT = 60;
% 
% imported_structure = struct2cell(load(append("Simulation_Data\Time_Series\data",string(DT),"min_filt.mat")));
% 
% wind_droplet_table = imported_structure{1};
% 
% for x = 1:440
%     svd_indexing(x) = append("svd_",string(x-1));
% end
% 
% for x = 1:22
%     dsdIndexing(x) = append("dsd_",string(x-1));
% end
% 
% for x = 1:20
%     dvdIndexing(x) = append("dvd_",string(x-1));
% end
% 
% dvd = wind_droplet_table{:,dvdIndexing};
% dsd = wind_droplet_table{:,dsdIndexing};
% 
% 
% svd = wind_droplet_table{:,svd_indexing};
% svdSize = size(svd);
% svd = reshape(svd', 20, 22, svdSize(1));  % Gives a matrix with terminal velocities on the first axis and Droplet diameters on the second
% 
% constructeddsd = permute(sum(svd,1),[3 2 1]);
% constructeddvd = permute(sum(svd,2),[3 1 2]);
% 
% 
% isequal(constructeddvd, dvd)
% isequal(constructeddsd, dsd)

% wind_speeds = linspace(3,35);
% v_mid = WindToBladeVelocity(wind_speeds,63) ;
% 
% plot(wind_speeds,v_mid);
% 
% xlabel("Wind Speed (m/s)");
% ylabel("Blade Speed (m/s)");
% grid("on")

% timestamps = wind_droplet_table{:,"dateTime"};
% interval = minutes(10);
% 
% fulltimestamps = (timestamps(1):interval:timestamps(end))';
% 
% missingTimestamps = setdiff(fulltimestamps, timestamps);


% Code to generate a figure of the distribution of terminal velocities

% imported_structure = struct2cell(load(append("Simulation_Data\Time_Series\",string(DT),"min_data_flatten.mat")));% Using the non-filtered data to match the joint FDF
% wind_droplet_table = imported_structure{1};
% d_bins = imported_structure{2};
% terminal_v_bins = [imported_structure{3} 11]; % The last index is added for the bin that exists to infinity. 


% The diameters and velocities assosiated with each of the bins in svd 



% svd = wind_droplet_table{:,svd_indexing};
% svdSize = size(svd);
% svd = reshape(svd', 20, 22, svdSize(1));  % Gives a matrix with terminal velocities on the first axis and Droplet diameters on the second
% 
% svd_total = sum(svd,3);
% 
% 
% dvd = wind_droplet_table{:,dvdIndexing};
% 
% droplet_velocities = sum(dvd,1);
% 
% 
% SpeedDropletPlot2(terminal_v_bins,d_bins,log10(svd_total),"");

imported_structure_filt = struct2cell(load(append("Simulation_Data\Time_Series\10min_data_filt.mat")));% Using the non-filtered data to match the joint FDF
imported_structure_unfilt = struct2cell(load(append("Simulation_Data\Time_Series\10min_data_unfilt.mat")));% Using the non-filtered data to match the joint FDF

d_lowers = imported_structure_filt{2};
temp = [d_lowers(2:end) 9];
d_mids = (d_lowers(1:end)+ temp)./2;
volumes = (4/3)*pi* (d_mids./2).^3;

table_filt = imported_structure_filt{1};
table_unfilt = imported_structure_unfilt{1};

rainfall_filt = table_filt{:,"rainfall"};
rainfall_unfilt = table_unfilt{:,"rainfall"};

rainfall_filt = sum(rainfall_filt);
rainfall_unfilt = sum(rainfall_unfilt);

for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end

% Gets the collumns of the joint SVD from the table
svd_filt = table_filt{:,svd_indexing};
svdSize = size(svd_filt);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd_filt = reshape(svd_filt', 20, 22, svdSize(1));  

% Gets the collumns of the joint SVD from the table
svd_unfilt = table_unfilt{:,svd_indexing};
svdSize = size(svd_unfilt);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd_unfilt = reshape(svd_unfilt', 20, 22, svdSize(1)); 


droplet_dist_filt = sum(svd_filt,1);
droplet_dist_filt = permute(droplet_dist_filt,[3 2 1]);

droplet_dist_unfilt = sum(svd_unfilt,1);
droplet_dist_unfilt = permute(droplet_dist_unfilt,[3 2 1]);

A = 0.0046*1000*1000;

droplet_volumes_filt = volumes.*droplet_dist_filt/A; % Convert to volume of water fallen in mm

droplet_volumes_unfilt = volumes.*droplet_dist_unfilt./A;



droplet_volumes_filt = sum(droplet_volumes_filt,"all")
droplet_volumes_unfilt = sum(droplet_volumes_unfilt,"all")

rainfall_filt
rainfall_unfilt

%plot(droplet_velocities)
