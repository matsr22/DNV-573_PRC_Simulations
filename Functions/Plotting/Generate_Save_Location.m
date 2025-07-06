function [global_run_number,folder_save_location] = Generate_Save_Location(config)


if config.use_best_distribution_PRC
    rainfall_type_str = "Best";
else
    rainfall_type_str = "Measured";
end
if all(mod(config.fdf_variable_chosen, 2) == 0) 
    plot_type_str = "Incident";
elseif all(mod(config.fdf_variable_chosen, 2) == 1)     
    plot_type_str = "Damage";
else
    error("Both Damage and Incident Present - Saving Not allowed")
end

if config.query_doing_PRC_analysis == "PRC"

    
    base_path = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Final Results\",config.query_doing_PRC_analysis,"\",config.version_number,"\",config.location_considered,"\");

    if ~config.enable_PRC % Ensure that preliminary assesment can be made before 
        query_iterate_run_number = true;
    else
        query_iterate_run_number = false;
    end
    global_run_number = Get_Next_Run_Number(base_path+"\counter.txt",query_iterate_run_number);

    folder_save_location = append(base_path,"\",rainfall_type_str,"\Run_Number_",string(global_run_number),"\");
else

    folder_save_location = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Final Results\",config.query_doing_PRC_analysis,"\",config.version_number,"\",config.location_considered,"\",plot_type_str,"\");
    global_run_number = [];
end
end