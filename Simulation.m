% Main Simulation

% Load in wind and rain data here:

% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value

d_bins = linspace(0.1,3,60); % Value in mm of start and stop points of each bin, allowing for varying size of bins
d_midpoints = (d_bins(1:end-1) + d_bins(2:end)) ./2; % Midpoint diameter of each bin

w_bins = linspace(0,40,60); % Value in ms^-1 of the wind speed start stop points of the bins
w_midpoints = (w_bins(1:end-1) + w_bins(2:end)) ./2; % Midpoint diameter of each bin

v_midpoints = WindToTip(w_midpoints,'IEA15MW_tip.xlsx');% Converts the wind speed to tip speed for use in the simulation


% This 2x2 matrix will contain the number of particles in each bin - used to calculate the overall damage

% Fake data for illustration purposes

[dd,ww] = meshgrid(d_midpoints, v_midpoints);

impingements_data = abs(sin(dd).*cos(cosh(ww)));



% Load RET data here:

VNdf = readtable('VN-Data.xlsx');
X = VNdf{:, 'N'};
Y = VNdf{:, 'V'};


d_ret = 1.1;


% Constants of the Simulation

% Constants irrespective of turbine/coating design

% These values are for water and are found in the RENER 2024 paper

Z_l = 1484000;
c_l = 1480;

% Made up values

CPInfo = readtable('Coating_Properties.xlsx'); % Protection data information placed here
coatingName = 'RENER_2024'; % Replace this name with the one referenced in Coating_Properties
coatingDes = CPInfo{:, coatingName};
[Z_s,Z_c,c_c,h_c] = deal(transpose(coatingDes))
% Assume normal incidence of droplets
alpha = 0;

v_chosen = 8.8; % This is the value extracted from the 95/95 V-N fit to be used in calculation of the springer constant



[xConf,yConf,m,b] = regression_confidence(X,Y);

m = -m; % I think this is right? Worth double checking though as will have a big impact on the simulation


NConf = interp1(xConf,yConf,v_chosen);

% Calculate the Raw Strength of the Material


springer_inital_modified = HammerStress(d_ret, v_chosen, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c) * ((NConf*d_ret^2)/8.9)^(1/m);

springer_raw = RawStrength(springer_inital_modified,d_ret, Z_c, Z_l, Z_s, c_c, c_l, h_c);

% Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 

[d_grid,v_grid] = meshgrid(d_midpoints,w_midpoints);


allowed_impingements =(8.9 ./ d_grid.^2) .* (ModifyStress(springer_raw,d_grid,Z_c, Z_l, Z_s, c_c, c_l, h_c)./ HammerStress(d_grid, v_grid, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c)).^m;

% Calculate Damage


damage_grid = impingements_data ./allowed_impingements;


%SpeedDropletPlot(w_bins,d_bins,impingements_data,"Incident Droplets");
%SpeedDropletPlot(w_bins,d_bins,allowed_impingements,"Allowed Impingements");
%SpeedDropletPlot(w_bins,d_bins,damage_grid,"Damage Caused");

disp(['The total damage caused to the turbine is: ', num2str(sum(damage_grid,"all"))])

%