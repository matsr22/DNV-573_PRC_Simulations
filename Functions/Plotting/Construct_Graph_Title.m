function [output_title] = Construct_Graph_Title(config,fdf_variable_chosen)
% Constructs the graph title used in the plotting algorithms

    % Normalised all have in their title a division by total
    % damage/rainfall
    normalise = config.normalise_plot;

    graph_origin_name = config.fdf_plotting_variables(fdf_variable_chosen);
        % Normalised (Divided by total sum value)
    if normalise
        if contains(graph_origin_name,"Droplet") && contains(graph_origin_name,"Incident")
            output_title = '$\log_{10}(n_v/n_{v,T})$';
        elseif contains(graph_origin_name,"Incident")
            % Incident Droplets
            output_title = '$\log_{10}(n_{O}/n_{O,T})$';
        elseif contains(graph_origin_name,"Erosibility")
            output_title = "$e/e_{T}$";
        else
            % Damage
            output_title = '$D_s/D_{s,T}$';
        end
    else
        % Unnormalised 
        if contains(graph_origin_name,"Droplet") && contains(graph_origin_name,"Incident")
            output_title = '$\log_{10}(n_v)$';
        elseif contains(graph_origin_name,"Incident")    
            % Incident Droplets
            output_title = '$\log_{10}(n_o)$';
        elseif contains(graph_origin_name,"Erosibility")
            output_title = "$e$";
        else
            % Damage
            output_title = '$D_s$';
        end
    end
end