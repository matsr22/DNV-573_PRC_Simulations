% Testing Environment
clear
clc
close all
% 
% DT = 60;
% 
% importedStructure = struct2cell(load(append("Simulation_Data\Time_Series\data",string(DT),"min_filt.mat")));
% 
% timeData = importedStructure{1};
% 
% for x = 1:440
%     svdIndexing(x) = append("svd_",string(x-1));
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
% dvd = timeData{:,dvdIndexing};
% dsd = timeData{:,dsdIndexing};
% 
% 
% svd = timeData{:,svdIndexing};
% svdSize = size(svd);
% svd = reshape(svd', 20, 22, svdSize(1));  % Gives a matrix with terminal velocities on the first axis and Droplet diameters on the second
% 
% constructeddsd = permute(sum(svd,1),[3 2 1]);
% constructeddvd = permute(sum(svd,2),[3 1 2]);
% 
% 
% isequal(constructeddvd, dvd)
% isequal(constructeddsd, dsd)

wind_speeds = 3:25;
v_mid = WindToVelocity(wind_speeds,'Simulation_Data\RENER2024\wind_omega_5MW.mat',1) * 9.5492;

plot(wind_speeds,v_mid);
xlim([3,25]);
ylim([0,50]);
xlabel("Wind Speed (m/s)");
ylabel("Rotor Speed (rpm)");
grid("on")