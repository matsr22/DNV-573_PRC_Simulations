function Plotting_Algorithms(plot_fdf,use_exact_w_s,wind_velocities,fdf_variable_chosen,damages,d_bins,n_s,n_droplets_air,location_considered,use_best_dist,normalise,version,ommision)
% Places wind velocity into bins rather than using the exact value - forPlott
% comparison purposes and plotting

% For Tex compatibility - there will be a better way to do this
if location_considered == "North_Sea"
    location_considered = "North Sea";
end
if normalise
    damage_prefix = "$\left(\frac{n}{N}\right) / D_s$";
    incident_prefix = "$\log_{10}{\frac{n_R}{n_T}}$";
    normalise_save_file = "Normalised";
else
    damage_prefix = "$\frac{n}{N}$";
    incident_prefix = "$\log_{10}{n_R}$";
    normalise_save_file = "";
end
if use_best_dist
    best_save = "Best";
else
    best_save = "Measured";
end
if use_best_dist == true
    suffix = "Best";
elseif use_best_dist == false
    suffix = "Measured";
else
    suffix = "Difference";
end
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
        [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
        wind_velocities = w_calc(indices)';
    end
    if (fdf_variable_chosen == 1) % Plot against Droplet Diameter
        damages_FDF =  zeros(length(w_calc),length(d_calc));
        for x=1:length(w_calc)
            wind = w_calc(x);
            mask = (wind_velocities == wind);
            damages_FDF(x,:) = sum(damages(mask, :), 1);
        end
        if normalise
            damages_FDF = damages_FDF/sum(damages_FDF,"all");
        end


        SpeedDropletPlot(d_bins,damages_FDF,damage_prefix +" - "+location_considered +" - " +suffix,"Damage_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"DSD"+"_"+version)

    elseif fdf_variable_chosen == 3 ||fdf_variable_chosen == 4  % Plot against mass weighted diameter
        mass_weighted_d_bins = d_bins;
        mass_weighted_d_bins = sort(mass_weighted_d_bins);
        mass_weighted_d_mid = (mass_weighted_d_bins(1:end-1)+mass_weighted_d_bins(2:end))./2;
        mass_w_diameters = sum(n_droplets_air.*d_calc.^4,2)./sum(n_droplets_air.*d_calc.^3,2); % Gets the mass weighted diameter for each

        [~, indices] = min(abs(mass_w_diameters - mass_weighted_d_mid), [], 2);
        mass_w_diameters_q = mass_weighted_d_mid(indices)';

        damages_m_w_d =  zeros(length(w_calc),length(mass_weighted_d_mid));
        frequency_m_w_d =  zeros(length(w_calc),length(mass_weighted_d_mid));
        erosibility_m_w_d =  zeros(length(w_calc),length(mass_weighted_d_mid));
        for w= 1:length(w_calc)
            for d =  1:length(mass_weighted_d_mid)
                wind = w_calc(w);
                m_w_d = mass_weighted_d_mid(d);
                damages_m_w_d(w,d) = sum(damages(wind == wind_velocities & m_w_d == mass_w_diameters_q,:),"all");
                frequency_m_w_d(w,d) = sum(n_droplets_air(wind == wind_velocities & m_w_d == mass_w_diameters_q,:),"all");
            end
        end
        if use_best_dist == true
            suffix = "Best";
        elseif use_best_dist == false
            suffix = "Measured";
        else
            suffix = "Difference";
        end
        if normalise
            damages_m_w_d = damages_m_w_d./(sum(damages_m_w_d,"all"));
            frequency_m_w_d = frequency_m_w_d./(sum(frequency_m_w_d,"all"));
        end
        if fdf_variable_chosen == 3
        SpeedDropletPlot(mass_weighted_d_bins,damages_m_w_d,damage_prefix +" - "+location_considered +" - " +suffix,"Damage_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"D_mass"+"_"+version,0:30,"D_{mass}")
        end
        
        non_zero_drops = frequency_m_w_d(frequency_m_w_d~=0);
        lowest_val = min(non_zero_drops);
        frequency_m_w_d(frequency_m_w_d==0) = lowest_val;
        if fdf_variable_chosen == 4
        SpeedDropletPlot(mass_weighted_d_bins,log10(frequency_m_w_d),incident_prefix +" - "+location_considered +" - " +suffix,"Incident_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"D_{mass}"+"_"+version,0:30,"D_{mass}")
        end
    elseif fdf_variable_chosen == 3 % Plot against total rainfall - not very useful
        rainfall_totals = sum(n_droplets_air.*(4/3).*pi.*(d_calc./2).^3,2);
        rainfall_bins = logspace(log10(5000),log10(m(rainfall_totals)),23);

        rainfall_mids = (rainfall_bins(1:end-1)+rainfall_bins(2:end))./2;

        [~,indices] = min(abs(rainfall_totals-rainfall_mids),[],2);

        rainfall_tot_q = rainfall_mids(indices)';

        damages_rainfall = zeros(length(w_calc),length(rainfall_mids));
        for w= 1:length(w_calc)
            for r =  1:length(rainfall_mids)
                wind = w_calc(w);
                rainfall = rainfall_mids(r);
                damages_rainfall(w,r) = sum(damages(wind == wind_velocities & rainfall == rainfall_tot_q,:),"all");
                frequency_rainfall(w,r) = numel(damages(wind == wind_velocities & rainfall == rainfall_tot_q,:));
            end
        end
        if fdf_variable_chosen == 5
        SpeedDropletPlot(rainfall_bins,damages_rainfall,damage_prefix +" - "+location_considered +" - " +suffix,"Damage_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"rainfall$"+"_"+version)
        hold on;
        ylabel("rainfall [mm]");
        hold off;
        end
        if fdf_variable_chosen == 6
        SpeedDropletPlot(rainfall_bins,frequency_rainfall,incident_prefix +" - "+location_considered +" - " +suffix,"Incident_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"rainfall"+"_"+version)
        hold on;
        ylabel("rainfall [mm]");
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
        if use_best_dist == true
            suffix = "Best";
        elseif use_best_dist == false
            suffix = "Measured";
        else
            suffix = "Difference";
        end
        
        SpeedDropletPlot(d_bins,incident_FDF,incident_prefix +" - "+location_considered +" - " +suffix,"Incident_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"DSD"+"_"+version)



    elseif fdf_variable_chosen ==7 || fdf_variable_chosen ==8
        median_d_bins = d_bins;
        median_d_bins = sort(median_d_bins);
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
        [~, indices] = min(abs(medians - median_d_mid), [], 2);
        median_q = median_d_mid(indices)';

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
        if use_best_dist == true
            suffix = "Best";
        elseif use_best_dist == false
            suffix = "Measured";
        else
            suffix = "Difference";
        end

        if normalise
            damages_median = damages_median./(sum(damages_median,"all"));
            frequency_median = frequency_median./(sum(frequency_median,"all"));
        end
        if fdf_variable_chosen ==7
        SpeedDropletPlot(median_d_bins,damages_median,damage_prefix +" - "+location_considered +" - " +suffix,"Damage_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"Median"+"_"+version,0:30,"Median Diameter[mm]")
        end
        lowest_val = 10^-7;
        frequency_median(frequency_median==0) = lowest_val;
        if fdf_variable_chosen ==8
        SpeedDropletPlot(median_d_bins,log10(frequency_median),incident_prefix +" - "+location_considered +" - " +suffix,"Incident_"+location_considered + "_"+normalise_save_file+"_"+best_save+"_"+"Median"+"_"+version,0:30,"Median Diameter[mm]")
        end
    end
    

    
end
end