function output_save_name = Construct_Save_Name(normalise,use_best_dist,enable_PRC,fdf_variable_chosen,location_considered,version)

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

    input_types = ["DSD","Dm","Rainfall","D0"];

    input_string = input_types(ceil(fdf_variable_chosen/2));
    
    if enable_PRC
        PRC_enabled_string = "PRC";
    else
        PRC_enabled_string = "";
    end

    final_string_array = [normalise_str,rainfall_source,input_string,PRC_enabled_string];

    final_string_array = final_string_array(final_string_array ~= "");

    output_save_name = strjoin(final_string_array,"_");
end




