function [damages_FDF,frequency_FDF,erosibility_FDF,parameter_bins] = Construct_FDFs(config,w_calc,wind_velocities,damages,d_bins,d_calc,n_droplets_air,plot_name)
    


    row_sums = sum(n_droplets_air, 2);              % Sum along rows
    zero_rows = ~(row_sums == 0);    % Find indices where sum is 0
    n_droplets_air = n_droplets_air(zero_rows,:);
    damages = damages(zero_rows,:);
    wind_velocities = wind_velocities(zero_rows,:);

    if config.use_exact_w_s % If the calculations in the code are not being simplified, simplify here
            wind_velocities = Bin_Continuous_Parameter(wind_velocities(:), w_calc);
    end

    if contains(plot_name,"Droplet") % Plot against Droplet Diameter
    damages_FDF = zeros(length(w_calc), length(d_calc));
    frequency_FDF = zeros(length(w_calc), length(d_calc));
    for x=1:length(w_calc)
        wind = w_calc(x);
        mask = (wind_velocities == wind);
        damages_FDF(x,:) = sum(damages(mask, :), 1);
        frequency_FDF(x,:) = sum(n_droplets_air(mask, :), 1);
    end
    erosibility_FDF = []; % Not useful for the DSD
    elseif contains(plot_name,"Mass")
        parameter_bins = d_bins;
        mass_weighted_d_mid = (parameter_bins(1:end-1) + parameter_bins(2:end)) ./ 2;


        mass_w_diameters = Calculate_Dmass(n_droplets_air, mass_weighted_d_mid, parameter_bins);
        % Remove 0 damages from damage and parameter

        mass_w_diameters_q = Bin_Continuous_Parameter(mass_w_diameters, mass_weighted_d_mid);

        [damages_FDF,frequency_FDF] = Create_Binned_FDFs(w_calc,mass_weighted_d_mid,damages,wind_velocities,mass_w_diameters_q);
    
        erosibility_FDF = damages_FDF./frequency_FDF;
        erosibility_FDF(isnan(erosibility_FDF)) = 0;
    elseif contains(plot_name,"Rainfall")

    


    rainfall_totals = Rainfall_From_Cubic_Meter(n_droplets_air, d_calc);
    

    parameter_bins = [linspace(0, 10, 23)];
    rainfall_mids = (parameter_bins(1:end-1) + parameter_bins(2:end)) ./ 2;
    rainfall_tot_q = Bin_Continuous_Parameter(rainfall_totals, rainfall_mids);


    [damages_FDF,frequency_FDF] = Create_Binned_FDFs(w_calc,rainfall_mids,damages,wind_velocities,rainfall_tot_q);

    erosibility_FDF = damages_FDF ./ frequency_FDF;
    erosibility_FDF(isnan(erosibility_FDF)) = 0;
    elseif contains(plot_name,"Median")
        [parameter_bins,median_d_mid,medians] = Calculate_Mmass(d_bins,n_droplets_air,d_calc);
        
        % No binning required for the median as it is allready a binned
        % parameter 
        [damages_FDF,frequency_FDF] = Create_Binned_FDFs(w_calc,median_d_mid,damages,wind_velocities,medians);
        
        erosibility_FDF = damages_FDF./frequency_FDF;
        erosibility_FDF(isnan(erosibility_FDF)) = 0;
    else
        error("Plot Name Incorrect")
    end
    
end