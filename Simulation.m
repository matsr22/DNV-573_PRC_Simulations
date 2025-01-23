clear
clc
% Main Simulation

% Load in wind and rain data here:

% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value

[w_bins,d_bins,w_mid,d_mid,matrix] = LoadCombinedDSD("myMap_turbine.mat");

v_mid = WindToTip(w_mid,'IEA15MW_tip.xlsx');% Converts the wind speed to tip speed for use in the simulation


% This 2x2 matrix will contain the number of particles in each bin - used to calculate the overall damage

% Fake data for illustration purposes

% Load RET data here:

% Ideally again this will be .mat files so I can import the d_ret as well

VNdf = readtable('VN-Data.xlsx');
X = VNdf{:, 'V'};
Y = VNdf{:, 'N'};


d_ret = 2.6;


% Constants of the Simulation

% Constants irrespective of turbine/coating design

% These values are for water and are found in the RENER 2024 paper

Z_l = 1484000;
c_l = 1480;

% Made up values

CPInfo = readtable('Coating_Properties.xlsx'); % Protection data information placed here
coatingName = 'RENER_2024'; % Replace this name with the one referenced in Coating_Properties
coatingDes = CPInfo{:, coatingName};
temp = num2cell(coatingDes');
[Z_s,Z_c,c_c,h_c] = temp{:};
% Assume normal incidence of droplets
alpha = 0;

v_chosen = 120; % This is the value extracted from the 95/95 V-N fit to be used in calculation of the springer constant



[xConf,yConf,m,b] = regression_confidence(X,Y);

NConf = interp1(xConf,yConf,v_chosen);

% Calculate the Raw Strength of the Material


springer_inital_modified = HammerStress(d_ret, v_chosen, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c) * ((NConf*d_ret^2)/8.9)^(1/m);



springer_raw = RawStrength(springer_inital_modified,d_ret, Z_c, Z_l, Z_s, c_c, c_l, h_c);

% Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 

[d_grid,v_grid] = meshgrid(d_mid,v_mid);



allowed_impingements =(8.9 ./ d_grid.^2) .*( (ModifyStress(springer_raw,d_grid,Z_c, Z_l, Z_s, c_c, c_l, h_c)./ HammerStress(d_grid, v_grid, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c)).^m);

% Calculate Damage


damage_grid = matrix ./allowed_impingements;


close all

SpeedDropletPlot(w_bins,d_bins,log(matrix'),"Incident Droplets");
SpeedDropletPlot(w_bins,d_bins,log(allowed_impingements'),"Allowed Impingements");
SpeedDropletPlot(w_bins,d_bins,damage_grid',"Damage Caused");

disp(['The total damage caused to the turbine is: ', num2str(sum(damage_grid,"all"))])

%

function [w_bins,d_bins,w_mid,d_mid,matrix] = LoadCombinedDSD(fileName)
    % Loads in three variables - a matrix of droplet frequencies and the corresponding bins for wind velocity and droplet velocites

    % Currently the method assumes that the bins are given in the following forms:

    % For WindSpeed, either the WindRange is given as the start and stop point for each bin, or the WindRange is given as just the start of each bin and the step size is assumed to be one between them

    % FOr the droplet size either dropSize is given as the start and stop point for each bin, or given as just the end point, with a missing leading 0.

    % The loaded matlab file must have Map, WindRange and dropSizes as its variable names 

    load(fileName);

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
        dropSizes = [0 dropSizes];
    end



    w_bins = WindRange;
    d_bins = dropSizes;

    d_mid = (dropSizes(1:(length(dropSizes)-1)) + dropSizes(2:length(dropSizes)))./2;
    w_mid = (WindRange(1:(length(WindRange)-1)) + WindRange(2:length(WindRange)))./2;

end