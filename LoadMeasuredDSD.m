function [w_bins,d_bins,w_mid,d_mid,matrix] = LoadMeasuredDSD(fileName)
    % Loads in three variables - a matrix of droplet frequencies and the corresponding bins for wind velocity and droplet velocites

    % Currently the method assumes that the bins are given in the following forms:

    % For WindSpeed, either the WindRange is given as the start and stop point for each bin, or the WindRange is given as just the start of each bin and the step size is assumed to be one between them

    % FOr the droplet size either dropSize is given as the start and stop point for each bin, or given as just the end point, with a missing leading 0.

    % The loaded matlab file must have Map, WindRange and dropSizes as its variable names 

    vars = load(fileName);
    WindRange = vars.WindRange;
    dropSizes = vars.dropSizes;
    Map = vars.Map;
    matrix = Map;
    matSize = size(matrix);

    if(matSize(1)>length(WindRange) || matSize(1)<(length(WindRange)-1))
        error("Size of Wind Bins not compatible with matrix size")
    end

    if(matSize(2)>length(dropSizes) || matSize(2)<(length(dropSizes)-1))
        error("Size of Droplet Bins not compatible with matrix size")
    end

    if (matSize(1) == length(WindRange))
        WindRange = [WindRange WindRange(length(WindRange))+1];
    end
    if(matSize(2) == length(dropSizes))
        dropSizes = [0 dropSizes ];
    end



    w_bins = WindRange;
    d_bins = dropSizes;

    d_mid = (dropSizes(1:(length(dropSizes)-1)) + dropSizes(2:length(dropSizes)))./2;
    w_mid = (WindRange(1:(length(WindRange)-1)) + WindRange(2:length(WindRange)))./2;

end
