function Plotting_Algorithms(plot_fdf,use_exact_w_s,wind_velocities,fdf_variable_chosen,damages,d_bins,n_s,n_droplets_air,location_considered,use_best_dist,normalise,version,ommision,enable_PRC,normalisation_damage)
% Places wind velocity into bins rather than using the exact value - forPlott
% comparison purposes and plotting

% As of 27/06/25 this is a very messy function with many different
% responsibilites and problems and needs a major overhaul

% 27/06/25 - Began restructure, more function useage now, still requires
% some updates - especially to flexibility around plotting of m_w_d and
% medians

% For Tex compatibility - there will be a better way to do this
if location_considered == "North_Sea"
    location_considered = "North Sea";
end

graph_title = Construct_Graph_Title(normalise,fdf_variable_chosen);
graph_save_name = Construct_Save_Name(normalise,use_best_dist,enable_PRC,fdf_variable_chosen,location_considered,version);



if ommision
    d_bins = d_bins(2:end);
    n_droplets_air =n_droplets_air(:,2:end);
    damages = damages(:,2:end);
end

if plot_fdf
    % Re-construct FDF:
    [w_calc,~] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
    d_calc = ((d_bins(1:end-1) + d_bins(2:end))./2);
    if use_exact_w_s % If the calculations in the code are not being simplified, simplify here
        wind_velocities = Bin_Continuous_Parameter(wind_velocities(:),w_calc);
    end
    if (fdf_variable_chosen == 1) % Plot against Droplet Diameter
        damages_FDF =  zeros(length(w_calc),length(d_calc));
        for x=1:length(w_calc)
            wind = w_calc(x);
            mask = (wind_velocities == wind);
            damages_FDF(x,:) = sum(damages(mask, :), 1);
        end
        if normalise
            damages_FDF = damages_FDF./normalisation_damage;
        end

        
        SpeedDropletPlot(d_bins,damages_FDF,graph_title,graph_save_name)

    elseif fdf_variable_chosen == 3 ||fdf_variable_chosen == 4  % Plot against mass weighted diameter

        % Allowing for adjustment of the mass weighted bins - don't have to
        % be identical to measured dsd bins
        mass_weighted_d_bins = d_bins;
        mass_weighted_d_mid = (mass_weighted_d_bins(1:end-1)+mass_weighted_d_bins(2:end))./2;

        mass_w_diameters = Calculate_Dmass(n_droplets_air,mass_weighted_d_mid,mass_weighted_d_bins); % Gets the mass weighted diameter for each

        mass_w_diameters_q = Bin_Continuous_Parameter(mass_w_diameters,mass_weighted_d_mid);

        damages_m_w_d =  zeros(length(w_calc),length(mass_weighted_d_mid));
        frequency_m_w_d =  zeros(length(w_calc),length(mass_weighted_d_mid));
        for w= 1:length(w_calc)
            for d =  1:length(mass_weighted_d_mid)
                wind = w_calc(w);
                m_w_d = mass_weighted_d_mid(d);
                damages_m_w_d(w,d) = sum(damages(wind == wind_velocities & m_w_d == mass_w_diameters_q,:),"all");
                frequency_m_w_d(w,d) = sum(n_droplets_air(wind == wind_velocities & m_w_d == mass_w_diameters_q,:),"all");
            end
        end
        if normalise
            damages_m_w_d = damages_m_w_d./normalisation_damage;
            frequency_m_w_d = frequency_m_w_d./(sum(frequency_m_w_d,"all"));
        end
        if fdf_variable_chosen == 3
        SpeedDropletPlot(mass_weighted_d_bins,damages_m_w_d,graph_title,graph_save_name,0:30,"D_{mass}")
        end
        
        non_zero_drops = frequency_m_w_d(frequency_m_w_d~=0);
        lowest_val = min(non_zero_drops);
        frequency_m_w_d(frequency_m_w_d==0) = lowest_val;
        if fdf_variable_chosen == 4
        SpeedDropletPlot(mass_weighted_d_bins,log10(frequency_m_w_d),graph_title,graph_save_name,0:30,"D_{mass}")
        end
    elseif fdf_variable_chosen == 5 || fdf_variable_chosen ==6 % Plot against total rainfall

        rainfall_totals = Rainfall_From_Cubic_Meter(n_droplets_air,d_calc);

        rainfall_bins = [linspace(0.1,10,23)];

        rainfall_mids = (rainfall_bins(1:end-1)+rainfall_bins(2:end))./2;

        rainfall_tot_q = Bin_Continuous_Parameter(rainfall_totals,rainfall_mids);

        damages_rainfall = zeros(length(w_calc),length(rainfall_mids));
        for w= 1:length(w_calc)
            for r =  1:length(rainfall_mids)
                wind = w_calc(w);
                rainfall = rainfall_mids(r);
                damages_rainfall(w,r) = sum(damages(wind == wind_velocities & rainfall == rainfall_tot_q,:),"all");
                frequency_rainfall(w,r) = sum(n_droplets_air(wind == wind_velocities & rainfall == rainfall_tot_q,:),"all");
            end
        end
        if normalise
            damages_rainfall = damages_rainfall./normalisation_damage;
            frequency_rainfall = frequency_rainfall./sum(frequency_rainfall,"all");
        end
        if fdf_variable_chosen == 5
        SpeedDropletPlot(rainfall_bins,damages_rainfall,graph_title,graph_save_name)
        hold on;
        ylabel("rainfall [mm/h]");
        hold off;
        end
        if fdf_variable_chosen == 6
        non_zero_drops = frequency_rainfall(frequency_rainfall~=0);
        lowest_val = 10^-6;
        frequency_rainfall(frequency_rainfall==0) = lowest_val;
        
        SpeedDropletPlot(rainfall_bins,log10(frequency_rainfall),graph_title,graph_save_name)
        hold on;
        ylabel("rainfall [mm/h]");
        hold off;
        end
    elseif fdf_variable_chosen == 2 % Plot total incident 
        incident_FDF =  zeros(length(w_calc),length(d_calc));
        for x=1:length(w_calc)
            wind = w_calc(x);
            mask = (wind_velocities == wind);
            incident_FDF(x,:) = sum(n_droplets_air(mask, :), 1);
        end
        if normalise
            incident_FDF = incident_FDF/sum(incident_FDF,"all");
        end
        non_zero_drops = incident_FDF(incident_FDF~=0);
        lowest_val = min(non_zero_drops);
        incident_FDF(incident_FDF==0) = lowest_val;
        incident_FDF = log10(incident_FDF);
        
        SpeedDropletPlot(d_bins,incident_FDF,graph_title,graph_save_name)



    elseif fdf_variable_chosen ==7 || fdf_variable_chosen ==8
        median_d_bins = d_bins;

        median_d_mid = (median_d_bins(1:end-1)+median_d_bins(2:end))./2;
        medians = zeros(size(n_droplets_air,1),1);
        for i = 1:size(n_droplets_air,1)


            frequencies = n_droplets_air(i,:) / sum(n_droplets_air(i,:));
            
            % Cumulative frequency
            cum_freq = cumsum(frequencies);
            
            % Find index where cumulative freq crosses 0.5
            median_idx = find(cum_freq >= 0.5, 1, 'first');
            
            if isempty(median_idx)
                medians(i) = 0;
            else
                 medians(i) = d_calc(median_idx(1));
            end
        end

        median_q = Bin_Continuous_Parameter(medians,median_d_mid);

        damages_median =  zeros(length(w_calc),length(median_d_mid));
        frequency_median =  zeros(length(w_calc),length(median_d_mid));
        for w= 1:length(w_calc)
            for d =  1:length(median_d_mid)
                wind = w_calc(w);
                median_calc = median_d_mid(d);
                damages_median(w,d) = sum(damages(wind == wind_velocities & median_calc == median_q,:),"all");
                frequency_median(w,d) = sum(n_droplets_air(wind == wind_velocities & median_calc == median_q,:),"all");
            end
        end
        

        if normalise
            damages_median = damages_median./normalisation_damage;
            frequency_median = frequency_median./(sum(frequency_median,"all"));
        end
        if fdf_variable_chosen ==7
        SpeedDropletPlot(median_d_bins,damages_median,graph_title ,graph_save_name,0:30,"Median Diameter[mm]")
        end
        lowest_val = 10^-7;
        frequency_median(frequency_median==0) = lowest_val;
        if fdf_variable_chosen ==8
        SpeedDropletPlot(median_d_bins,log10(frequency_median),graph_title,graph_save_name,0:30,"Median Diameter[mm]")
        end
    end
    

    
end
end

function binned_data = Bin_Continuous_Parameter(continuous_data,bin_mid_point)
[~, indices] = min(abs(continuous_data - bin_mid_point), [], 2);
binned_data = bin_mid_point(indices)';
end