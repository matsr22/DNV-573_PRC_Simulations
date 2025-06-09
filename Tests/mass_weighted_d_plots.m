addpath("..");

DT = 1; % Controls what time resolution is used for the simulation

location_considered_1 = "Lampedusa";
location_considered_2 = "Lancaster"; 

ommit_first_droplets = true;

% Indexes for later exluding the first data class if ommiting
if ommit_first_droplets
    index_best = 2:22;
else
    index_best = 1:22;
end


% Load in the tables
[data_table1,d_calc,d_bins] =UnpackWindRainData("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lampedusa\Combined 23-24\1min_data_filt.mat");% Using the non-filtered data to match the joint FDF
[data_table2,d_calc,d_bins] =UnpackWindRainData(append("..\Simulation_Data\",location_considered_2,"\",num2str(DT),"min_data_filt.mat"));% Using the non-filtered data to match the joint FDF


% Define the volume of a drop for calculation of the rainfall rate 
volumes = (4/3)*pi* (d_calc./2).^3;




for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end



% Gets the collumns of the dsd from the table
droplets_measured1 = data_table1{:,dsd_indexing};

% Sensor capture area in m^2
A = 0.00456;

% Gets the rainfall from the measured distribtion for each location - Units
% mm
rainfalls1 = sum(volumes.*droplets_measured1./(A*1e6),2)/(DT/60); 

mass_weighted_diameters1 = sum(droplets_measured1.*d_calc.^4,2)./sum(droplets_measured1.*d_calc.^3,2); % Gets the mass weighted diameter for each

droplets_measured2 = data_table2{:,dsd_indexing};

rainfalls2 = sum(volumes.*droplets_measured2./(A*1e6),2)/(DT/60); 

mass_weighted_diameters2 = sum(droplets_measured2.*d_calc.^4,2)./sum(droplets_measured2.*d_calc.^3,2); % Gets the mass weighted diameter for each

% 0/0 creates some NAN values - remove these 
indexes1 = ~(rainfalls1==0) & ~isnan(rainfalls1)&~isnan(mass_weighted_diameters1);
indexes2 = ~(rainfalls2==0) & ~isnan(rainfalls2)&~isnan(mass_weighted_diameters2);

rainfalls1 = rainfalls1(indexes1);
mass_weighted_diameters1 = mass_weighted_diameters1(indexes1);

rainfalls2 = rainfalls2(indexes2);
mass_weighted_diameters2 = mass_weighted_diameters2(indexes2);


% Define range for best fit plottng
x_range = logspace(-1,2,150);

% Construct a Best distribution for every point across the considered range
best_distribution = ConstructBestDistributions(x_range,d_calc,d_bins);


%Calculate Mass Weighted Diameters for each rainfall
mass_weighted_diameters_best = sum(best_distribution(:,index_best).*d_calc(index_best).^4,2)./sum(best_distribution(:,index_best).*d_calc(index_best).^3,2);

figure;
markersize = 5;

% Scatter Measured Data on plot
scatter(rainfalls1,mass_weighted_diameters1,markersize,'Marker','d');
hold on;

scatter(rainfalls2,mass_weighted_diameters2,markersize,'Marker','^');

% Plot Best with same fit used for the measured data 
plot(x_range,fit_data(x_range,mass_weighted_diameters_best',x_range),'k')


% Fit and plot to the measured data
plot(x_range,fit_data(rainfalls1,mass_weighted_diameters1,x_range), 'Color', '#B8860B', 'LineWidth', 2);
plot(x_range,fit_data(rainfalls2,mass_weighted_diameters2,x_range), 'Color', '#006400', 'LineWidth', 2);


set(gca, 'XScale', 'log'); 
xlabel('R (mm/hr)');
ylabel('D_{mass} (mm)');
xlim([0.1 1000])
legend(location_considered_1, location_considered_2,'Best',location_considered_1+" fit",location_considered_2+" fit");

function D_masses_result = fit_data(rainfall, D_masses, rainfall_output)
    % Remove any invalid values
    valid = rainfall > 0 & D_masses > 0;
    R = rainfall(valid);
    D = D_masses(valid);

    % Define power-law model: D = a * R^b
    model = @(params, x) params(1) * x.^params(2);

    % Initial guess: [a, b]
    initial_guess = [0.5, 0.03];

    % Fit using nonlinear least squares
    params_fit = lsqcurvefit(model, initial_guess, R, D);

    % Evaluate at new rainfall_output
    D_masses_result = model(params_fit, rainfall_output);
end