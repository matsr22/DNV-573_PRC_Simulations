function [median_d_bins,median_d_mid,medians] = Calculate_Mmass(d_bins,n_droplets_air,d_calc)
        median_d_bins = d_bins;
        median_d_mid = (median_d_bins(1:end-1) + median_d_bins(2:end)) ./ 2;
        
        d_widths = d_bins(2:end)-d_bins(1:end-1);
        
        % Gets the amount of water in each droplet class bin
        water_per_droplet = (n_droplets_air./d_widths).*d_calc.^3;

        cumsum_water = cumsum(water_per_droplet,2);
        half_total_waters = sum(water_per_droplet,2)./2;

        mask = cumsum_water>half_total_waters;

        [~, median_idx] = max(mask, [], 2); % Find location of first point over 50%


        medians = d_calc(median_idx)'; % Inverted to ensure dimensional consistency 

        set_0s = half_total_waters == 0;
        medians(set_0s) = 0;



end