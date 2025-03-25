function [w_calc,d_calc,matrix] = LoadMeasuredDSD(fileName,d_calc_location)
    % Loads in three variables - a matrix of droplet frequencies and the corresponding bins for wind velocity and droplet velocites

    % Currently the method assumes that the bins are given in the following forms:

    % For WindSpeed - The bins are given as the lower values of the bin,
    % the last one being unbounded.
    % For DropletSizes - The bins are given as the lowest value in each,
    % last one being unbounded
    % The loaded matlab file must have Map, WindRange and dropSizes as its variable names 
    
    if nargin <2
        d_calc_location = 2;% Choses which point in the bin the calculation is done from, default is 1 - the lower value, as used by RENER and Rome. Can choose 2 - the center of the bin or 3 the upper of the bin
    end
    vars = load(fileName);
    w_calc = vars.WindRange + 0.5; % Corresponds to the centre of each bin - Bad Code, only works for this specific dataset

    if d_calc_location == 1
        d_calc = vars.dropSizes; % Corresponds to the lower of each bin, as discussed 
    elseif d_calc_location ==2
        temp = [vars.dropSizes(2:end) 8.5];
        d_calc = (vars.dropSizes + temp)./2;
    else
        d_calc = [vars.dropSizes(2:end) 8.5];
    end
    Map = vars.Map;
    matrix = Map;

    

end
