function [global_run_number,folder_save_location] = Generate_Save_Location(query_doing_PRC_analysis,normalise_plot,ommit_first_droplet_class,use_best_distribution_PRC,version_number,location_considered,enable_PRC,fdf_variable_chosen)
if query_doing_PRC_analysis == "PRC"
    if normalise_plot
    normalise_string = "Normalised";
    else
        normalise_string = "Unnormalised";
    end
    if ommit_first_droplet_class
        droplet_class_save_string = "First Droplet Class Omitted";
    else
        droplet_class_save_string = "No droplet Omission";
    end
    if use_best_distribution_PRC
        best_save_string = "Best";
    else
        best_save_string = "Measured";
    end
    
    base_path = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\15MW Comparisons\",droplet_class_save_string,"\",query_doing_PRC_analysis,"\",version_number,"\",location_considered,"\");

    if ~enable_PRC % Ensure that preliminary assesment can be made before 
        query_iterate_run_number = true;
    else
        query_iterate_run_number = false;
    end
    global_run_number = Get_Next_Run_Number(base_path+"\counter.txt",query_iterate_run_number);

    folder_save_location = append(base_path,"\",best_save_string,"\Run_Number_",string(global_run_number),"\");
else
    if all(mod(fdf_variable_chosen, 2) == 0) 
        damage_or_normalised = "Incident Drops";
    elseif all(mod(fdf_variable_chosen, 2) == 1)     
        damage_or_normalised = "Damage";
    else
    error("Both Damage and Incident Present - Saving Not allowed")
    end
    folder_save_location = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\15MW Comparisons\",droplet_class_save_string,"\",query_doing_PRC_analysis,"\",normalise_string,"\",version_number,"\",location_considered,"\",damage_or_normalised,"\");
end
end