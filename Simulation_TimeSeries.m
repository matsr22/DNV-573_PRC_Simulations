

%
% Configuration of the Simulation
%
% ---------------------------
% Analysis - DATASET USED
% ---------------------------
location_considered = "North_Sea"; % Determines which location is being analysed, options: [Lancaster], [Lecce], [Lampedusa], [North_Sea]
DT = 10; % Temporal Resolution of the Data, expressed in minutes
% ---------------------------
% Analysis - TURBINE OPTIONS
% ---------------------------
turbine_used = "15MW";% Gives which turbine is considered by the analysis options: [3MW] WINDPACT Turbine, [5MW] NREL Turbine and [15MW] NREL Turbine
coating_used = 'ThreeM'; % Alters the coating properties used in the analysis, options: [AAP] (from the RENER2024 paper), [ThreeM] (Case 2 in Sanchez Et al), [ORE] (Case 3 in Sanchez Et al)
consider_all_strips = true; % Controls if all strips are calculated or just the outermost one
% ---------------------------
% Analysis - RAINFALL OPTIONS
% ---------------------------
use_filtered_data = true;
consider_terminal_velocities = true; % If false sets all terminal velocities to 1, as is done in the joint FDF
use_measured_terminal_velocites = false; % If considering terminal velocities, use measured rather than emperical
use_best_distribution = true;
ommit_first_droplet_class = false;

% ---------------------------
% Analysis - WIND OPTIONS
% ---------------------------
use_extrapolated_wind_data = true;
use_exact_w_s = true; % Controls if the exact wind speed is used or  the wind is placed into bins and then the average of that bin is used

% ---------------------------
% Analysis - PLOTTING OPTIONS
% ---------------------------
plot_fdf = true; % Controls if the simulation is plotted or if just damage values are shown
fdf_plotting_variables = ["Droplet_Diameter_Damage","Droplet_Diameter_Incident","Mass_Weighted_Diameter_Damage","Mass_Weighted_Diameter_Incident","Rainfall_Damage","Rainfall_Incident","Median_Diameter_Damage","Median_Diameter_Incident"];
fdf_variable_chosen = []; % Can either be a vector of all graphs to produce or a scalar 
normalise_plot = 1; % 1 for true 0 for false - Could do with changing
folder_save_location = "C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\15MW Comparisons\First Droplet Class Omitted\Non-PRC\Normalised\V_2\";
version_number = "V_2";
% ---------------------------
% Analysis - PRECIPITATION REACTIVE CONTROL
% ---------------------------
enable_PRC = false;
curtailing_wind_speed = 7; % Wind speed that curtailing occurs at when PRC criteria is met - must match one of the precalculated curves

curtailing_criteria = ["Mass_Weighted_Diameter","Median_Diameter","Damage"];
curtailing_criteria_chosen = 1;

% Rain Metric Criteria
curtailing_lower_criteria = 0.5;
curtailing_upper_criteria = 1.25;

% Wind Metric Criteria
wind_speed_lower = 10;
wind_speed_upper = 25;
% ---------------------------
% Analysis - Main Algorithm
% ---------------------------

strip_radii = load(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Turbine_Curves\Turbine_Data_",turbine_used,".mat"),"radii"); % Strips, indexed 1 to 6 of those considered in the paper
strip_radii = strip_radii.radii;

if use_best_distribution
    suffix = 'best';
elseif use_filtered_data
    suffix = "filt";
else
    suffix = "unfilt";
end

if consider_all_strips
    strip_index = 1:6;
else
    strip_index = 6;
end

% Modifies the file accessed to be that specific to the hub height extrapolation
% required of each turbine. 5MW not added as this is not yet relevant to
% analysis we are doing. 
if use_extrapolated_wind_data
    if turbine_used == "3MW"
        suffix = append(suffix,"_119_ext");
    elseif turbine_used == "15MW"
        suffix = append(suffix,"_150_ext");
    end
end

%
% Import Data
%

[wind_droplet_table, d_calc,d_bins,terminal_v_bins] = UnpackWindRainData(append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\",location_considered,"\",string(DT),"min_data_",suffix,".mat"),ommit_first_droplet_class); 


% Remove Timestamps in the data with NaN values
wind_droplet_table = wind_droplet_table(~isnan(wind_droplet_table.("wind_avg")), :);



data_quantity_days = (size(wind_droplet_table,1) * DT)/(60*24); % From the number of elements in the table, gives number of days - used for damage calculations


for i = strip_index

if use_best_distribution
    col_names = "dsd_" + string(0:21);
    n_droplets_air = wind_droplet_table{:, col_names};
else

% Generates a vector of the variables of the joint size velocity
% distribution indexes
for x = 1:440
    svd_indexing(x) = append("svd_",string(x-1));
end
% Gets the collumns of the joint SVD from the table
svd = wind_droplet_table{:,svd_indexing};
svdSize = size(svd);

% Gives a matrix with terminal velocities on the first axis and droplet diameters on the second
svd = reshape(svd', 20, 22, svdSize(1));  

if  consider_terminal_velocities & use_measured_terminal_velocites
    t_v_calculators = (terminal_v_bins(1:end-1) +terminal_v_bins(2:end))./2; % Currently Gets the midpoint of each of the terminal velocities
    [svd_diameters,svd_vels] = meshgrid(d_calc,t_v_calculators); % Creates grid with 1-1 correspondence with the Size-Velocity Distribution with the droplet size and velocity at each point
    svd = svd./(svd_vels); % Area converts from Impacts to per m^2, then the terminal velocity of the drops gives per m^3 (Time ommited as it cancels later - see Incident_Droplet_Calculations.pdf for an explanation)
end
n_droplets_air = sum(svd,1)./(DT*60); % Sum across all droplet terminal velocities
n_droplets_air = permute(n_droplets_air,[3 2 1]); % Remove droplet terminal velocity dimension

A = 0.00456; % area in m^2 of sensor
n_droplets_air = n_droplets_air./A;

if consider_terminal_velocities & ~use_measured_terminal_velocites
    v_parametric = @(d) 9.65 - 10.3.*exp(-0.6.*d); % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
    t_v_from_diameters = v_parametric(d_calc);
    n_droplets_air = n_droplets_air./t_v_from_diameters;
end
end

% --------------------------
% Load in time series wind data:
% --------------------------
wind_velocities = wind_droplet_table{:,"wind_avg"};

if ~ use_exact_w_s
     [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
     [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
     wind_velocities = w_calc(indices)';
end

% Convert the wind speeds to the corresponding speed of the blade at a
% each indexuse

% PRECIPITATION REACTIVE CONTROL 

if enable_PRC
    
    % Prep the dataset for PRC - Calculate Mass_W_Diameter, Rainfall and
    % Median. 

    mass_weighted_diameters = sum(n_droplets_air.*d_calc.^4,2)./sum(n_droplets_air.*d_calc.^3,2); % Gets the mass weighted diameter for each


    medians = zeros(size(n_droplets_air,1),1);
    for time_stamp = 1:size(n_droplets_air,1)


        frequencies = n_droplets_air(time_stamp,:) / sum(n_droplets_air(time_stamp,:));
        
        % Cumulative frequency
        cum_freq = cumsum(frequencies);
        
        % Find index where cumulative freq crosses 0.5
        median_idx = find(cum_freq >= 0.5, 1, 'first');
        
        if isempty(median_idx)
            medians(time_stamp) = 0;
        else
             medians(time_stamp) = d_calc(median_idx(1));
        end
    end


    


    damage_criteria = 0.000062;
    
    switch curtailing_criteria_chosen
        case 1
            curtailing_locations = mass_weighted_diameters >= curtailing_lower_criteria & mass_weighted_diameters <= curtailing_upper_criteria & wind_speed_lower < wind_velocities & wind_speed_upper > wind_velocities ;
        case 2
            curtailing_locations = medians >= curtailing_lower_criteria & medians <= curtailing_upper_criteria & wind_speed_lower < wind_velocities & wind_speed_upper > wind_velocities;
        case 3
            curtailing_locations = time_series_damage_base >= damage_criteria;
        otherwise 
            error("Selected curtailing criteria does not exist")
    end
    
    [impact_velocities, powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),turbine_used,curtailing_locations,curtailing_wind_speed);
    time_curtailed = ((DT/60)/24)*sum(curtailing_locations);
    total_energy_production_curt = sum(2.77778e-10*(powers*DT*60));


else

[impact_velocities,powers] = WindToBladeVelocity(wind_velocities,strip_radii(i),turbine_used);
%total_energy_production_regular = sum(2.77778e-10*(powers*DT*60));
end








% Create matrix of number of droplets incident on blade per m^2
n_s = n_droplets_air .* impact_velocities.*(DT*60); % Convert back to per m^2 with the blade velocities (Ensuring data is along correct axis)

% Now creates a matrix with both the droplet diameters and blade velocities
% for every droplet diameter bin for every time step.
[diameter_mesh,blade_vel_mesh] = meshgrid(d_calc,impact_velocities); 


computed_vals = GetSpringerStrength(coating_used); % Sets up the springer strength (Given in the RENER paper) - Ideally move this and other similar preparation steps outside the loop

allowed_impingements = CalculateAllowedImpingements(computed_vals,blade_vel_mesh,diameter_mesh); % Calculates the allowed impingements for each blade velocity and diameter combination

damages = n_s./allowed_impingements; 

time_series_damage = sum(damages,2); % Gets the damage for every timestep


droplet_diameter_damage = sum(damages,1); % Gets the damage for each droplet diameter

total_damage = sum(damages,'all');
strip_damage(i) = total_damage;
strip_hours(i) = (1/total_damage)*data_quantity_days*24; % This was one of the differences between the Rome research team's results and mine, I am using the correct slightly modified number of days in the dataset, they were using number of days in a year

end
%%
for i = 1:length(fdf_variable_chosen)
    Plotting_Algorithms(plot_fdf,use_exact_w_s,wind_velocities,fdf_variable_chosen(i),damages,d_bins,n_s,n_droplets_air,location_considered,use_best_distribution,normalise_plot,version_number,ommit_first_droplet_class);
end

if ~isempty(fdf_variable_chosen)
% Get all figure handles (including hidden ones)
figHandles = findall(0, 'Type', 'figure');

max_vals_incident = [];
min_vals_incident = [];
max_vals_damage = [];
for k = 1:length(figHandles)
    fig = figHandles(k);
    
    % Find all imagesc objects in the figure
    imageObjs = findall(fig, 'Type', 'image');
    
    axesList = findall(fig, 'Type', 'axes');
    
    
    ax = axesList(1);
    titleText = get(get(ax, 'Title'), 'String');
    
    if isempty(imageObjs)
        fprintf('  No imagesc plots found.\n');
    elseif contains(titleText, 'log', 'IgnoreCase', true)
        for i = 1:length(imageObjs)
            img = imageObjs(i);
            cdata = img.CData; % Extract the matrix from imagesc
            
            % Get the maximum value of the matrix
            max_vals_incident(end+1) = max(cdata(:));
            min_vals_incident(end+1) = min(cdata(:));
            
        end
    else
        for i = 1:length(imageObjs)
        img = imageObjs(i);
        cdata = img.CData; % Extract the matrix from imagesc
        
        % Get the maximum value of the matrix
        max_vals_damage(end+1) = max(cdata(:));
        end
    end
end

newCLim_incident = [-5 ColourLimCeilAdjust(max(max_vals_incident))];
newClim_damage = [0 ColourLimCeilAdjust(max(max_vals_damage))];

for k = 1:length(figHandles)
    fig = figHandles(k);
    
    % Find all axes in the figure
    axHandles = findall(fig, 'Type', 'axes');

    
    
    for j = 1:length(axHandles)
        ax = axHandles(j);

        titleText = get(get(ax, 'Title'), 'String');
        
        % Check if this axes has an image (imagesc)
        img = findall(ax, 'Type', 'image');
        
        if ~isempty(img)
            % Set new color limits

            if contains(titleText, 'log', 'IgnoreCase', true)
                 ax.CLim = newCLim_incident;
            else
                ax.CLim = newClim_damage;
            end
        end
    end

    savedName = fig.UserData;
    savefig(fig, folder_save_location+savedName);
end
end

if use_best_distribution
    title_part = "Best";
else
    title_part = "Measured";
end
Plot_Damages_D(damages,d_calc,title_part+"_"+location_considered)


disp('Incubation Time Predicted:')

disp(strip_hours(strip_index))

excel_string = sprintf('%g\t', string(strip_hours(strip_index)));
excel_string(end) = [];  % remove trailing tab
clipboard('copy', excel_string);  % copy to clipboard







