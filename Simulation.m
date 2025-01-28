clear
clc
close all
% Main Simulation


% The following are data imports:
[w_bins,d_bins,w_mid,d_mid,matrix] = LoadCombinedDSD("myMap_turbine.mat");% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value
VNdf = readtable('VN-Data.xlsx');
CPInfo = readtable('Coating_Properties.xlsx'); % Protection data information placed here
v_mid = WindToTip(w_mid,'IEA15MW_tip.xlsx');% Converts the wind speed to tip speed for use in the simulation


% RET processing:
X = VNdf{:, 'V'};
Y = VNdf{:, 'N'};
d_ret = 2.6; % In future this should come from an assosiated .mat file


% Constants of the Simulation

% Constants irrespective of turbine/coating design

% These values are for water and are found in the RENER 2024 paper

Z_l = 1484000;
c_l = 1480;



coatingName = 'RENER_2024'; % Replace this name with the one referenced in Coating_Properties
coatingDes = CPInfo{:, coatingName};
temp = num2cell(coatingDes');
[Z_s,Z_c,c_c,h_c] = temp{:};

% Assume normal incidence of droplets
alpha = 0;
consider_impingement_efficency = true;
v_chosen = 120; % This is the value extracted from the 95/95 V-N fit to be used in calculation of the springer constant



[xConf,yConf,m,b] = regression_confidence(X,Y);

if ~((min(xConf) < v_chosen) && (v_chosen < max(xConf)))
    error("V_chosen not in range of input")
end


NConf = interp1(xConf,yConf,v_chosen);

% Calculate the Raw Strength of the Material

springer_inital_modified = HammerStress(d_ret, v_chosen, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c) * ((NConf*d_ret^2)/8.9)^(1/m);

springer_raw = RawStrength(springer_inital_modified,d_ret, Z_c, Z_l, Z_s, c_c, c_l, h_c);

% Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 

[d_grid,v_grid] = meshgrid(d_mid,v_mid);

allowed_impingements =(8.9 ./ d_grid.^2) .*( (ModifyStress(springer_raw,d_grid,Z_c, Z_l, Z_s, c_c, c_l, h_c)./ HammerStress(d_grid, v_grid, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c)).^m);


% Number of impacts on blade:

matrix = matrix .* v_grid;

% Consider impingement efficency

if consider_impingement_efficency
    matrix = matrix .* (1 - exp(-15*d_grid));
end

% Calculate Damage

damage_grid = matrix ./allowed_impingements;




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

function [w_bins,d_bins,w_mid,d_mid,matrix] = LoadStatisticalDSD(w_weibull_params,rainfall,w_fidelity,d_fidelity,w_max,d_max)
    

    % This function should return the number of droplets per cubic meter of air per year
    if nargin < 6
        d_max = 8;
    end
    if nargin <5
        w_max = 30;
    end
    if nargin <4
        d_fidelity = 20;
    end
    if nargin < 3 
        w_fidelity = 20;
    end

    [k,c] = w_weibull_params{:};

    w_weibull = @(v) (k/c)*((v./c).^(k-1))*exp(-(v/c).^k);

    W = @(R) 67*R.^0.846;
    V = @(D) (1/6)*pi*(D.^3);
    a = @(R) 1.3*R.^0.232;
    k_B = 2.25;

    best = @(D,R) (W(R)./V(D)) * ((K_B*D.^(K_B-1))/(a(R).^k_B))*exp(-(D/a(R)).^k_B);

    if length(rainfall) == 3
        total_rainfall = rainfall(1);
        sigma_r = rainfall(2);
        mean_r = rainfall(3);
    else 
        total_rainfall = sum(rainfall);
        sigma_r = std(log(rainfall));
        mean_r = mean(log(rainfall));
    end

    rainfall_fdf = @(R) (total_rainfall ./ (R .* sigma_r .* sqrt(2 * pi))).*exp(-0.5 * ((log(R) - mean_r) ./ sigma_r).^2 - (mean_r + (sigma_r.^2) / 2));

    combined_rain_best = @(D,R) rainfall_fdf(R).*best(D,R);

    N_0 = @(D) integral(@(R) combined_rain_best(R,D),0,inf);

    droplet_fdf = @(v,D) w_weibull(v).*N_0(D);

    w_bins = linspace(0,w_max,w_fidelity);
    d_bins = linspace(0,d_max,d_fidelity);
    w_mid = 0.5*w_bins(1:(length(w_bins)-1))*w_bins(2:end);
    d_mid = 0.5*d_bins(1:(length(d_bins)-1))*d_bins(2:end);


    matrix = zeros((length(d_bins)-1),(length(w_bins)-1));
    for i = 1:(length(d_bins)-1)
        for x = 1:(length(w_bins)-1)
            matrix(i,x) = integral2(droplet_fdf,w_bins(x),w_bins(x+1),d_bins(i),d_bins(i+1));
        end
    end
end
