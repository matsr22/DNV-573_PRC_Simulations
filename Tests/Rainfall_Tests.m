


% This test asseses if the total rainfall in the datasets I have are the
% same as in the RENER paper

location_considered = "Lampedusa";

best_filt = "filt"; % Choose either [best] data or measured [filt] data

exclude_first_droplet_bin = true;

DT = 10; % Controls what time resolution is used for the simulation


[table,d_calc,d_bins] = Unpack_Wind_Rain_Data(append("..\Simulation_Data\",location_considered,"\",num2str(DT),"min_data_",best_filt,"_150_ext.mat"),exclude_first_droplet_bin);% Using the non-filtered data to match the joint FDF


volumes = (4/3)*pi* (d_calc./2).^3;


for x = 1:22
    dsd_indexing(x) = append("dsd_",string(x-1));
end



% Gets the collumns of the dsd from the table
droplet_dist = table{:,dsd_indexing};


Am = 0.00456; % Area in m^2
Amm = Am*1000*1000; % Area in mm^2

 % Terminal velocity in mm per hour
t_v_from_diameters = Terminal_V_From_D(d_calc);

format shortG
% Convert to rainfall  in mm - multiply number of droplets by the volume of
% each to get total rain volume in mm^3 then divide by area of disdrometer

% Best is recorded in per m^3, Measured is pure numbers
if best_filt == "filt"
    rainfalls = sum((droplet_dist.*volumes)./Amm,2); % Total rain at each time step
else
    rainfalls= table.rainfall_rate*(DT/60);
    %rainfalls = sum(((droplet_dist.*Am.*t_v_from_diameters*(DT*60)).*volumes)./Amm,2);
end
    



% Sum across timesteps and droplet diameters
rainfall = sum(rainfalls,"all")






% Function to remove the patched data in the table - unuses atm

function new_table = RestructureTable(input_table)

    % This function removes data not in the domain of the 1 year we are
    % looking for. 

    t_vals = input_table{:,"dateTime"};
    t_vals = datetime(t_vals);



    % Now fill in the missing data

    % Data needs to be copied from the entire month of July in 20

    july_index_start = find(year(t_vals)==2017&month(t_vals)==7,1,"first");
    july_index_end = find(year(t_vals)==2017&month(t_vals)==7,1,"last");

    index_start_insertion = find(year(t_vals)==2019&month(t_vals)==6,1,"last");
    index_end_insertion = find(year(t_vals)==2019&month(t_vals)==8,1,"first");

    data_to_insert = input_table(july_index_start:july_index_end,:);

    updated_timestamps = vertcat(data_to_insert{:,"dateTime"});

    %updated_timestamps = datetime(cell2mat(updated_timestamps));
    updated_timestamps.Year = 2019;
    %updated_timestamps = num2cell(updated_timestamps);

    data_to_insert{:,"dateTime"} = updated_timestamps;





    table_1 = input_table(1:index_start_insertion,:);

    table_2 = input_table(index_end_insertion:end,:);

    %input_table = [table_1;data_to_insert;table_2;];

        % Find the indexes in the table that correspond to First time step of
    % October 2018 and last time step of 30 Sep 2019
    t_vals = input_table{:,"dateTime"};
    t_vals = datetime(t_vals);

    target_start_year = 2018;
    target_start_month = 10;
    start_day_index = find(year(t_vals) == target_start_year & month(t_vals) == target_start_month, 1, 'first');

    
    
    target_end_year = 2019;
    target_end_month = 9;
    target_end_day = 30;
    
    end_day_index = find(year(t_vals) == target_end_year & month(t_vals) == target_end_month & day(t_vals) == target_end_day , 1, 'last');



    % In the RENER24 Paper, data is described as missing between the 22nd
    % and 26th of Sep 2019. This is accurate
    % However it says to fill in use the corresponding dates in 2017. This
    % data also does not exist.

    % For now I will ignore as it will be a small modification


    
    new_table = input_table(start_day_index:end_day_index,:);


end
