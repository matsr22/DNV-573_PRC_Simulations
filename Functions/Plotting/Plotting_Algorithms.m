function Plotting_Algorithms(config,wind_velocities,fdf_variable_chosen,damages,d_bins,n_s,n_droplets_air,normalisation_damage)
% Places wind velocity into bins rather than using the exact value - forPlott
% comparison purposes and plotting

% As of 27/06/25 this is a very messy function with many different
% responsibilites and problems and needs a major overhaul

% 27/06/25 - Began restructure, more function useage now, still requires
% some updates - especially to flexibility around plotting of m_w_d and
% medians

    old_config_query = config.query_iterate;
    config.query_iterate = false;
    [folder_save_location,~] = Generate_Save_Location(config);
    config.query_iterate = old_config_query;

    graph_title = Construct_Graph_Title(config,fdf_variable_chosen);
    graph_save_name = folder_save_location + Construct_Save_Name(config,fdf_variable_chosen);

    plot_name = config.fdf_plotting_variables(fdf_variable_chosen);


    d_bins = d_bins(2:end);
    n_droplets_air = n_droplets_air(:,2:end);
    damages = damages(:,2:end);



    if config.plot_fdf
        % Re-construct FDF:
        [w_calc,~] = LoadMeasuredDSD("Simulation_Data\RENER2024\myMap_turbine.mat");
        d_calc = ((d_bins(1:end-1) + d_bins(2:end))./2);
        if contains(plot_name,"Droplet") % Plot against Droplet Diameter
            
            [damages_FDF,incident_FDF] = Construct_FDFs(config,w_calc,wind_velocities,damages,d_bins,d_calc,n_droplets_air,plot_name);
            if config.normalise_plot
                damages_FDF = damages_FDF ./ normalisation_damage;
                incident_FDF = incident_FDF / sum(incident_FDF, "all");
            end
            if contains(plot_name,"Damage")
                SpeedDropletPlot(d_bins, damages_FDF, graph_title, graph_save_name)
            elseif contains(plot_name,"Incident")
                lowest_val = 10^-7;
                incident_FDF(incident_FDF == 0) = lowest_val;
                incident_FDF = log10(incident_FDF);
                SpeedDropletPlot(d_bins, incident_FDF, graph_title, graph_save_name)
            else
                error("Plot not a valid name")
            end
   

    
        elseif contains(plot_name,"Mass")

            [damages_m_w_d,frequency_m_w_d,erosibility,mass_weighted_d_bins] = Construct_FDFs(config,w_calc,wind_velocities,damages,d_bins,d_calc,n_droplets_air,plot_name);

            if config.normalise_plot
                damages_m_w_d = damages_m_w_d ./ normalisation_damage;
                frequency_m_w_d = frequency_m_w_d ./ sum(frequency_m_w_d, "all");
                erosibility = erosibility./sum(erosibility,"all");
            end
            if contains(plot_name,"Damage")
                SpeedDropletPlot(mass_weighted_d_bins, damages_m_w_d, graph_title, graph_save_name, 0:30, "D_{m} [mm]")
            
            elseif contains(plot_name,"Incident")            
                lowest_val = 10^-7;
                frequency_m_w_d(frequency_m_w_d == 0) = lowest_val;
                SpeedDropletPlot(mass_weighted_d_bins, log10(frequency_m_w_d), graph_title, graph_save_name, 0:30, "D_{m} [mm]")
            elseif contains(plot_name,"Erosibility")   
                contains(plot_name,"Erosibility")
                SpeedDropletPlot(mass_weighted_d_bins,erosibility,graph_title,graph_save_name,0:30,"D_{m} [mm]")
            else
                error("Plot Name Not Valid")
            end
    
        elseif contains(plot_name,"Rainfall")

            [damages_rainfall,frequency_rainfall,erosibility,rainfall_bins] = Construct_FDFs(config,w_calc,wind_velocities,damages,d_bins,d_calc,n_droplets_air,plot_name);
            if config.normalise_plot
                damages_rainfall = damages_rainfall ./ normalisation_damage;
                frequency_rainfall = frequency_rainfall ./ sum(frequency_rainfall, "all");
                erosibility = erosibility ./sum(erosibility,"all");
            end
            if contains(plot_name,"Damage")
                SpeedDropletPlot(rainfall_bins, damages_rainfall, graph_title, graph_save_name, 0:30,"rainfall [mm/h]")
            
            elseif contains(plot_name,"Incident")
                lowest_val = 10^-7;
                frequency_rainfall(frequency_rainfall == 0) = lowest_val;
                SpeedDropletPlot(rainfall_bins, log10(frequency_rainfall), graph_title, graph_save_name,  0:30,"rainfall [mm/h]")

            elseif contains(plot_name,"Erosibility")
                SpeedDropletPlot(rainfall_bins, erosibility, graph_title, graph_save_name, 0:30,"rainfall [mm/h]")
            else
                error("Plot Name Not Valid")
            end
    

    
        elseif contains(plot_name,"Median")

            [damages_median,frequency_median,erosibility,median_d_bins] = Construct_FDFs(config,w_calc,wind_velocities,damages,d_bins,d_calc,n_droplets_air,plot_name);

            if config.normalise_plot
                damages_median = damages_median ./ normalisation_damage;
                frequency_median = frequency_median ./ sum(frequency_median, "all");
                erosibility = erosibility ./sum(erosibility,"all");
            end
            if contains(plot_name,"Damage")
                SpeedDropletPlot(median_d_bins, damages_median, graph_title, graph_save_name, 0:30, "D_{0} [mm]")
            
            elseif contains(plot_name,"Incident")
                lowest_val = 10^-7;
                frequency_median(frequency_median == 0) = lowest_val;
                SpeedDropletPlot(median_d_bins, log10(frequency_median), graph_title, graph_save_name, 0:30, "D_{0} [mm]")
            elseif contains(plot_name,"Erosibility")
                SpeedDropletPlot(median_d_bins, erosibility, graph_title, graph_save_name, 0:30, "D_{0} [mm]")
            
            else
                error("Plot Named Not Valid")
            end
        end
        if config.plot_hor_lim_line
            hold on;
            if config.fdf_variable_chosen == 3
                input_bins = d_bins;
                query_point = config.curtailing_lower_criteria;
            elseif config.fdf_variable_chosen == 6
                input_bins = rainfall_bins;
                query_point = config.curtailing_rainfall_lower;
            end
            y_bins = 0:length(input_bins)-1;
            y_val = interp1(input_bins,flip(y_bins),query_point) +0.5; % For some reason, I actually have no clue how ImageSC works
            plot([config.curtailing_wind_speed 30], [y_val y_val],'k','LineWidth',2)
            hold off;
        end
    end
end

