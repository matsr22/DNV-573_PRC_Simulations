
close all;

addpath(genpath('..\Functions\'))
% --------------------------
% Load in time series rain data:
% --------------------------
imported_structure = struct2cell(load("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_unfilt.mat")); % Converts to cells

% Extract table of wind-rain values
output_table = imported_structure{1};

% The top of the top bin being 10m/s is a slightly arbitary choice as it is
% actually infinity but we must assume some realistic average size of the
% droplets contained in this bin

% Droplet diameter bins 
d_bins = [imported_structure{2} 10]; % The bins are provided by the definition by Elisa, both lower and upper defined

% Terminal Velocity Bins
terminal_v_bins = [0 imported_structure{3} 20]; % The bins are provided for both upper and lower by Elisa 



% The diameters and velocities assosiated with each of the bins in svd 
% Use the midpoint for both
d_calc = (d_bins(1:end-1) + d_bins(2:end))./2; 


for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end





% Gets the collumns of the joint SVD from the table
svd = output_table{:,svd_indexing};
svdSize = size(svd);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd = reshape(svd', 20, 22, svdSize(1));

SpeedDropletPlot(d_bins,log(sum(svd,3)),"-","-",terminal_v_bins,"D [mm]","V_t [m/s]")

% Deletes any data corresponding to the first droplet clas

