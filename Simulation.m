% Main Simulation

% Load in wind and rain data here:

% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value

d_bins = linspace(0.1,3,50); % Value in mm of start and stop points of each bin, allowing for varying size of bins
d_midpoints = (d_bins(1:end-1) + d_bins(2:end)) ./2; % Midpoint diameter of each bin

w_bins = linspace(0,40,50); % Value in ms^-1 of the wind speed start stop points of the bins
w_midpoints = (w_bins(1:end-1) + w_bins(2:end)) ./2; % Midpoint diameter of each bin


% This 2x2 matrix will contain the number of particles in each bin - used to calculate the overall damage
impingements_data = zeros([length(d_vals)-1 length(w_vals)-1]);

% Load RET data here:

VNdf = readtable('H:\Engineering\Simplified DTU code\VN-Data.xlsx');
X = VNdf{:, 'N [Impacts/m^2]'};
Y = VNdf{:, 'V [m/s]'};
d_ret;




% Constants of the Simulation

Z_l = 1.48e6;

% Made up values

Z_s = 1e6;
Z_c = 3e6;

% Assume normal incidence of droplets
alpha = 90;

c_l = 1440;
c_c = 2700;

h_c = 1e-3;

v_chosen; % This is the value extracted from the V-N curve to be used in calculation of the springer constant



xConf,yConf,fitting = regression_confidence(X,Y);

NConf = interp1(xConf,yConf,v_chosen);

springer_inital_modified = HammerStress(d_ret, v_chosen, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c) * ((NConf*d_ret^2)/8.9)^(1/fitting(1));

springer_raw = RawStrength(springer_inital_modified,d_ret, Z_c, Z_l, Z_s, c_c, c_l, h_c);

v_midpoints = WindToTip(w_midpoints,'H:\Engineering\Simplified DTU code\IEA15MW_tip');


[d_grid,v_grid] = meshgrid(d_midpoints,v_midpoints);

allowed_impingements =(8.9 ./ d_grid.^2) .* (ModifyStress(springer_raw,d_grid,Z_c, Z_l, Z_s, c_c, c_l, h_c)./ HammerStress(d_grid, w_grid, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c)).^fitting(1);

% Calculate Damage

damage_grid = impingements_data ./allowed_impingements;


%