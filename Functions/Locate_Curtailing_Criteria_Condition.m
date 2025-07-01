

% %%%%%%%%%%% IMPORTANT %%%%%%%%%%%%%%%

% ROADWORKS

% THIS FILE CURRENTLY RELIES ON VARIABLES EXISTING IN THE WORKSPACE RATHER THAN IMPORTED
% DIRECTLY INTO THE FUNCTION - THIS MUST BE RESOLVED BEFORE THIS FUNCTION CAN BE USED
% AGAIN          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_from_peak = true;

threshold_wind = 9;

percent_damage_thresholds = [0.5 0.7 0.9]; % Damage as a percentage of maximum 

for i = 1:length(percent_damage_thresholds)

percent_damage_thresh = percent_damage_thresholds(i);
d_widths = d_bins(2:end)-d_bins(1:end-1);

mass_weighted_diameters = sum((n_droplets_air./d_widths).*d_calc.^4,2)./sum((n_droplets_air./d_widths).*d_calc.^3,2);

rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air,d_calc); 


parameter = rainfalls; % Change based on which parameter the criteria is being selected for
parameter_name = "Rainfall";
% Gets both a damage and the parameter for each time step
parameter = sum(parameter,2);
damages_analysis = sum(damages,2); 
damages_analysis = damages_analysis(wind_velocities>=threshold_wind);

% Sorts the parameter from smallest to largest and gets the original
% indexes
[parameter_sorted,indexes] = sort(parameter(wind_velocities>=threshold_wind));

% Arranges the damages in the same way as the parameter
damage_analysis = damages_analysis(indexes);

total_damage = sum(damages,"all");

if start_from_peak

% Locate sweeping maximum 

% Sweep in reasonably large width:

width = round(length(damage_analysis)/10);

index_end = width;
index_start = 1;

return_index = 0;
current_maximum = 0;

while index_end<= length(damage_analysis)
    current_value = sum(damage_analysis(index_start:index_end));
    if current_value > current_maximum
        current_maximum  = current_value;
        return_index = round((index_end-index_start)/2 + index_start);
    end
    index_end = index_end+1;
    index_start = index_start+1;
end

if current_maximum == 0
    error("No values were found")
end


% Now expand from central point until correct damage has been captured
start_point = parameter_sorted(return_index)

range_parameter = max(parameter) - min(parameter);

damage_sweep_res = range_parameter/1000;

current_window_size = damage_sweep_res;

current_total_damage = 0;



while current_total_damage< total_damage*percent_damage_thresh

[~,low_index] = min(abs(parameter_sorted-(start_point-current_window_size)));
[~,high_index] = min(abs(parameter_sorted-(start_point+current_window_size)));

current_total_damage = sum(damage_analysis(low_index:high_index));
parameter_low = parameter_sorted(low_index);
parameter_high = parameter_sorted(high_index);
current_window_size = current_window_size+damage_sweep_res;
end
else
    start_point = 10 % Assuming this is only being used for rainfall
    step = 0.001; % Assuming again only for rainfall
    current_window_size = step
    current_total_damage = 0;
    
    while current_total_damage < total_damage*percent_damage_thresh
        [~,low_index] = min(abs(parameter_sorted-(start_point-current_window_size)));
        
        current_total_damage = sum(damage_analysis(low_index:end));
        current_window_size = current_window_size+step;

        parameter_low = parameter_sorted(low_index);
    end
    parameter_high = "-";
end

Write_Excel_Table(["location_considered","Best/Measured","Curtailing_Wind_Speed","Percent_Damage_Threshold","Parameter Name","Parameter_Upper_Threshold","Parameter_Lower_Threshold"]',...
    [location_considered,title_part,threshold_wind,string(percent_damage_thresh*100),parameter_name,string(parameter_high),string(parameter_low)]'...
    ,"Curtailing_Criteria_Find.xlsx",1);




end
