function [output_table,d_calc,d_bins,terminal_v_bins] = Unpack_Wind_Rain_Data(file_name,ommit_first_droplets,ommit_lowest_rainfalls)
% This function unpacks data from the file - currently in a cell array

% It also does some pre-processing of the data, according to certain flags
% -ROADWORKS - this is not a very robust way of doing things and should be
% improved - relies on order etc

% INPUTS:
% file_name - the name of the file to be modified 
% ommit_first)droplets - removes droplets in the lowest droplet bin -
% corresponds to <0.185 for specific disdrometer
% ommit_lowest_rainfalls - removes any rainfalls lower than 0.1mm/h

% OUTPUTS:
% output_table - the synchronous wind and rain measurements
% d_calc - the midpoint of each droplet size bin - used for calculations
% d_bins - the start and end points of each droplet size bin
% terminal_v_bins - the start and end points of each terminal velocity bin

if nargin<2
    ommit_first_droplets = true; % Default to removing first droplets as we will now do
end
if nargin<3
    ommit_lowest_rainfalls = false; % This is not allways done - for example in the North Sea data
end

% --------------------------
% Load in time series rain data:
% --------------------------
imported_structure = struct2cell(load(file_name)); % Converts to cells

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


if ommit_first_droplets
    % Go through both dsd and svd and clear to 0 any values assosiated with
    % the first bins
    try
    output_table{:, "dsd_0"} = 0;
    end
    % Generates a vector of the variables of the joint size velocity
    % distribution indexes
    try
    for x = 1:440
        svd_indexing(x) = append("svd_",string(x-1));
    end

    


    
    % Gets the collumns of the joint SVD from the table
    svd = output_table{:,svd_indexing};
    svdSize = size(svd);
    
    % Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
    svd = reshape(svd', 20, 22, svdSize(1)); 

    % Deletes any data corresponding to the first droplet class
    svd(:,1,:) = 0;

    % Reshapes back into origninal format
    svd = reshape(svd,440,svdSize(1));
    svd = svd';

    % Re writes data to the table
    output_table{:,svd_indexing} = svd;
    end
end

if ommit_lowest_rainfalls
    
    if ~contains(file_name,"best")
        % If the data is best produced - accurate rainfall figures are
        % given by the rainfall rate collumn, volumetric sum would
        % introduce a small bias
        rainfalls = output_table.rainfall_mm_hr;
        index_locations = rainfalls<0.1;
        
        dsd_indexing = "dsd_" + string(0:21);
        svd_indexing = "svd_" + string(0:439);
        output_table{index_locations,dsd_indexing} = 0;
        output_table{index_locations,svd_indexing} = 0;
    else

        % If non-best data is used then volumetric sum gives identical
        % results to the rainfall so it is used for consistency
        dsd_indexing = "dsd_" + string(0:21);
        n_droplets_air = output_table{:,dsd_indexing};
        rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air,d_calc);
        index_locations = rainfalls<0.1;
        output_table{index_locations,dsd_indexing} = 0;

    end
end

end

