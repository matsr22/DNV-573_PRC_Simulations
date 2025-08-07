function output_save_name = Construct_Save_Name(config,fdf_variable_chosen)
    
    normalise = config.normalise_plot;
    use_best_dist = config.use_best_distribution_simulation;
    enable_PRC = config.enable_PRC;

    if normalise
        normalise_str = "Normalised";
    else
        normalise_str = "Unnormalised";
    end

    if use_best_dist
        rainfall_source = "Best";
    else
        rainfall_source = "Measured";
    end

    input_string = Assign_Input_String(config,fdf_variable_chosen);
    
    if enable_PRC
        PRC_enabled_string = "PRC";
    else
        PRC_enabled_string = "";
    end

    final_string_array = [normalise_str,rainfall_source,input_string,PRC_enabled_string];

    final_string_array = final_string_array(final_string_array ~= "");

    output_save_name = strjoin(final_string_array,"_");
end

function input_string = Assign_Input_String(config,fdf_variable_chosen)
    
   plot_name = config.fdf_plotting_variables(fdf_variable_chosen);

   if contains(plot_name,"Droplet")
       input_string = "DSD";
   elseif contains(plot_name,"Mass")
       input_string = "Dm";
   elseif contains(plot_name,"Rainfall")
       input_string = "Rainfall";   
   elseif contains(plot_name,"Median")
       input_string = "D0";
   else
       error("Graph Name Not Valid")
   end

end


