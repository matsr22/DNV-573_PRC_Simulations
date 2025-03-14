% Testing Environment
clear
clc
close all

% The following code tests the joint size velocity distribution is
% consistent with the dsd and the dvd in the code 

DT = 60;

imported_structure = struct2cell(load(append("..\Simulation_Data\Time_Series_Lancaster\",string(DT),"min_data_filt.mat")));

wind_droplet_table = imported_structure{1};

for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end

for x = 1:22
    dsdIndexing(x) = append("dsd_",string(x-1));
end

for x = 1:20
    dvdIndexing(x) = append("dvd_",string(x-1));
end

dvd = wind_droplet_table{:,dvdIndexing};
dsd = wind_droplet_table{:,dsdIndexing};


svd = wind_droplet_table{:,svd_indexing};
svdSize = size(svd);
svd = reshape(svd', 20, 22, svdSize(1));  % Gives a matrix with terminal velocities on the first axis and Droplet diameters on the second

constructeddsd = permute(sum(svd,1),[3 2 1]);
constructeddvd = permute(sum(svd,2),[3 1 2]);


isequal(constructeddvd, dvd)
isequal(constructeddsd, dsd)