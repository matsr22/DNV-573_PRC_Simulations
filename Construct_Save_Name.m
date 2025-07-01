function output_save_name = Construct_Save_Name(normalise,use_best_dist,enable_PRC,fdf_variable_chosen,location_considered,version)

    if mod(fdf_variable_chosen,2) == 0 
        damage_or_incident = "Damage";
    else
        damage_or_incident = "Incident";
    end

    if normalise
        normalise_string = "Normalised";
    else
        normalise_string = "Unnormalised";
    end

    if use_best_dist
        rainfall_source = "Best";
    else
        rainfall_source = "Measured";
    end

    input_types = ["DSD","Dmass","Rainfall","Median"];

    input_string = input_types(ceil(fdf_variable_chosen/2));
    
    if enable_PRC && mod(fdf_variable_chosen,2) == 1 
        PRC_enabled_string = "PRC";
    elseif mod(fdf_variable_chosen,2) == 1 
        PRC_enabled_string = "UNCURT";
    else
        PRC_enabled_string = "";
    end

    output_save_name = strjoin([damage_or_incident,location_considered,normalise_string,rainfall_source,input_string,version,PRC_enabled_string],"_");
end




