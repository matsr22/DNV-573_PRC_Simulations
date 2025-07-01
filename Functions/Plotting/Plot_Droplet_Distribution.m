function Plot_Droplet_Distribution(x_data, data_series_1,data_series_2,data_series_1_name,data_series_2_name,title_name)

    % Compares two different droplet incident distributions, for example
    % BEST or MEASURED for the same site or LANCASTER VS LAMPEDUSA

    % Requires both to be in units of per m^3
    
    figure;
    semilogy(x_data, data_series_1, 'k', 'LineWidth', 1.2); % 'k' = black
    hold on;
    semilogy(x_data,data_series_2, 'r', 'LineWidth', 1.2); % 'r' = red
    
    % Axis labels
    xlabel('d [mm]');
    ylabel('Average Droplets per Unit Volume  [1/m^3]');
    
    % Grid and box
    grid on;
    box on;
    
    % Legend
    legend(data_series_1_name, data_series_2_name, 'Location', 'northeast');
    title(title_name)
    hold off;
end