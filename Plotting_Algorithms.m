function Plotting_Algorithms(plot_fdf,use_exact_w_s,wind_velocities,fdf_variable_chosen,damages,d_bins,n_s,n_droplets_air,location_considered,use_best_dist)
% Places wind velocity into bins rather than using the exact value - forPlott
% comparison purposes and plotting
if plot_fdf
    % Re-construct FDF:
    [w_calc,d_calc] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
    if use_exact_w_s % If the calculations in the code are not being simplified, simplify here
        [~, indices] = min(abs(wind_velocities(:) - w_calc), [], 2); % Gets for each exact wind velocity, the index of the wind velocity that is the bin this velocity falls under
        wind_velocities = w_calc(indices)';
    end
    if (fdf_variable_chosen == 1) % Plot against Droplet Diameter
        normalise = false;
        damages_FDF =  zeros(length(w_calc),length(d_calc));
        for x=1:length(w_calc)
            wind = w_calc(x);
            mask = (wind_velocities == wind);
            damages_FDF(x,:) = sum(damages(mask, :), 1);
        end
        if normalise
            damages_FDF = damages_FDF/sum(damages_FDF,"all");
        end
        if use_best_dist == true
            suffix = "Best";
        elseif use_best_dist == false
            suffix = "Measured";
        else
            suffix = "Difference";
        end
        SpeedDropletPlot(d_bins,damages_FDF,"n/N - "+location_considered +" - " +suffix)
        % hold on;
        % clim([0 4e-3])
        % hold off;
    elseif fdf_variable_chosen == 2 % Plot against mass weighted diameter
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
        SpeedDropletPlot(mass_weighted_d_bins,damages_m_w_d,"n/N - "+location_considered +" - " +suffix,0:30,"D_{mass}[mm]")
        hold on;
        clim([0 1e-2]);
        hold off;
        SpeedDropletPlot(mass_weighted_d_bins,log10(frequency_m_w_d),"log_{10} n - "+location_considered +" - " +suffix,0:30,"D_{mass}[mm]")
        hold on;
        clim([0 6]);
        hold off;
    elseif fdf_variable_chosen == 3 % Plot against total rainfall - not very useful
        rainfall_totals = sum(n_droplets_air.*(4/3).*pi.*(d_calc./2).^3,2);
        rainfall_bins = logspace(log10(5000),log10(max(rainfall_totals)),23);

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
        SpeedDropletPlot(rainfall_bins,damages_rainfall,"n/N - Rainfall")
        hold on;
        ylabel("rainfall [mm]");
        hold off;
        SpeedDropletPlot(rainfall_bins,frequency_rainfall,"Number_Impingements - Rainfall")
        hold on;
        ylabel("rainfall [mm]");
        hold off;
        SpeedDropletPlot(rainfall_bins,damages_rainfall./frequency_rainfall,"Erosability - Rainfall")
        hold on;
        ylabel("rainfall [mm]");
        hold off;
    elseif fdf_variable_chosen == 4 % Plot total incident 
        normalise = false;

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
        lowest_val = 10^-9;
        incident_FDF(incident_FDF==0) = lowest_val;
        incident_FDF = log10(incident_FDF);
        if use_best_dist == true
            suffix = "Best";
        elseif use_best_dist == false
            suffix = "Measured";
        else
            suffix = "Difference";
        end

        SpeedDropletPlot(d_bins,incident_FDF,"log_{10} n - "+location_considered +" - " +suffix)

        if ~normalise
            
            hold on;
            clim([-2 6])
            hold off;
        else
            hold on;
            clim([-9 -1])
            hold off;
        end

    elseif fdf_variable_chosen ==5
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
        SpeedDropletPlot(median_d_bins,damages_median,"n/N - "+location_considered +" - " +suffix,0:30,"Median Diameter[mm]")
        hold on;
        clim([0 2e-2]);
        hold off;
        SpeedDropletPlot(median_d_bins,log10(frequency_median),"log_{10} n - "+location_considered +" - " +suffix,0:30,"Median Diameter[mm]")
        hold on;
        clim([0 6]);
        hold off;
        
    end
    

    
end
end