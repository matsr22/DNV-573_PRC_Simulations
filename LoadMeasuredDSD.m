function [w_calc,d_calc,matrix] = LoadMeasuredDSD(fileName)
    % Loads in three variables - a matrix of droplet frequencies and the corresponding bins for wind velocity and droplet velocites

    % Currently the method assumes that the bins are given in the following forms:

    % For WindSpeed - The bins are given as the lower values of the bin,
    % the last one being unbounded.
    % For DropletSizes - The bins are given as the lowest value in each,
    % last one being unbounded
    % The loaded matlab file must have Map, WindRange and dropSizes as its variable names 

    vars = load(fileName);
    w_calc = vars.WindRange + 0.5; % Corresponds to the centre of each bin
    d_calc = vars.dropSizes;% Corresponds to the lower of each bin, as discussed 
    Map = vars.Map;
    matrix = Map;

    

end
