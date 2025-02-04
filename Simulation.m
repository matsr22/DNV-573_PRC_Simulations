clear
clc
close all
% Main Simulation


% The following are data imports:
weibull_params = load("weibull_metmast.mat");
rainfall = load("annual_rainfall_RENER.mat");

[w_bins,d_bins,w_mid,d_mid,matrix] = LoadStatisticalDSD({weibull_params.k,weibull_params.c},rainfall.TB_rain);% This data is loaded in the form of bins with each start/stop point of each bin having a numeric value
CPInfo = readtable('Coating_Properties.xlsx'); % Protection data information placed here
v_mid = WindToTip(w_mid,'NREL5MW_tip.xlsx');% Converts the wind speed to tip speed for use in the simulation

% RET processing:

d_ret = 2.61; % In future this should come from an assosiated .mat file - currently from RENR
v_chosen = 120; % This is the value extracted from the 95/95 V-N fit to be used in calculation of the springer constant

% The following code is used to run the RET analysis, as I don't currently have the 
%{
VNdf = readtable('VN-Data.xlsx');
X = VNdf{:, 'V'};
Y = VNdf{:, 'N'};
Y = Y *1e-6;
[xConf,yConf,m,b] = regression_confidence(X,Y);
if ~((min(xConf) < v_chosen) && (v_chosen < max(xConf)))
    error("V_chosen not in range of input")
end
Nfit = interp1(xConf,yConf,v_chosen)
%}


m=4.97;
b=1.3007e13;
Nfit = 1e6*10^(log10(b) - m *log10(v_chosen)); % Coefficent out the front to convert from mm^2 to m^2



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
alpha = 40;
consider_impingement_efficency = true;





% Equations

Z_frac = @(Z_1,Z_2) (Z_1 - Z_2) / (Z_1 + Z_2);
Theta = @(d) (c_c / c_l) .* ((1 + Z_l / Z_s) ./ (1 + Z_c / Z_s)) .* (2 ./ (1 + Z_l / Z_c)) .* (d ./ h_c);
K_Bar = @(d) (1-exp(-Theta(d)))./(1-Z_frac(Z_s,Z_c)*Z_frac(Z_l,Z_c));
HammerPressure = @(v) (Z_l .* v .* cosd(alpha)) ./ (1 + (Z_l ./ Z_c));
HammerPressure(v_chosen)
HammerStress = @(d,v) ((1 + Z_frac(Z_s, Z_c)) / (1 - Z_frac(Z_s, Z_c) * Z_frac(Z_l, Z_c))) .* (1- Z_frac(Z_s, Z_c)*((1 + Z_frac(Z_l, Z_c)) / (1 + Z_frac(Z_s, Z_c))).*((1 - exp(-Theta(d))) ./ Theta(d))) .* HammerPressure(v);
RawStrength = @(S_ec,d) (1+2*K_Bar(d)*abs(Z_frac(Z_s,Z_c)))*S_ec;
ModifyStress = @(S_c,d) S_c./(1+2*K_Bar(d).*abs(Z_frac(Z_s,Z_c)));

% Calculate the Raw Strength of the Material

springer_inital_modified = HammerStress(d_ret, v_chosen) * ((Nfit*d_ret^2)/8.9)^(1/m);


springer_raw = RawStrength(springer_inital_modified,d_ret);

% Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 

[d_grid,v_grid] = meshgrid(d_mid,v_mid);

allowed_impingements =(8.9 ./ d_grid.^2) .*( (ModifyStress(springer_raw,d_grid)./ HammerStress(d_grid, v_grid)).^m);


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

tot_damage = sum(damage_grid,"all");
disp(['The total damage caused to the turbine is: ', num2str(tot_damage)])
Hours  = (1/tot_damage)*365*24;
disp(['Number of Hours ', num2str(Hours)])



%




