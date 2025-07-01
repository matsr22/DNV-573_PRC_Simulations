function [global_run_number,folder_save_location] = Generate_Save_Location(query_doing_PRC_analysis,droplet_class_save_string,version_number,location_considered,enable_PRC,best_save_string,fdf_variable_chosen,normalise_string)

if normalise
    normalise_string = "Normalised";
else
    normalise_string = "Unnormalised";
end




if query_doing_PRC_analysis == "PRC"
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