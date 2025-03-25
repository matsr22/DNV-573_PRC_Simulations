% 
% 
% 
% timestamps = wind_droplet_table{:,"dateTime"};
% interval = minutes(10);
% 
% fulltimestamps = (timestamps(1):interval:timestamps(end))';
% 
% missingTimestamps = setdiff(fulltimestamps, timestamps);
% 
% 
% % Code to generate a figure of the distribution of terminal velocities
% 
% imported_structure = struct2cell(load(append("Simulation_Data\Time_Series\",string(DT),"min_data_flatten.mat")));% Using the non-filtered data to match the joint FDF
% wind_droplet_table = imported_structure{1};
% d_bins = imported_structure{2};
% terminal_v_bins = [imported_structure{3} 11]; % The last index is added for the bin that exists to infinity. 
% 
% 
% % The diameters and velocities assosiated with each of the bins in svd 
% 
% 
% 
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
% 
% 
% %plot(droplet_velocities)

GetSpringerStrength("x3M_Case_2");

