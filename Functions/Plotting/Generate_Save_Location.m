function [folder_save_location,global_run_number] = Generate_Save_Location(config)


if config.use_best_distribution_PRC
    rainfall_type_str = "Best";
else
    rainfall_type_str = "Measured";
end
if all(contains(config.fdf_plotting_variables(config.fdf_variable_chosen),"Incident")) 
    plot_type_str = "Incident";
elseif all(contains(config.fdf_plotting_variables(config.fdf_variable_chosen),"Damage"))     
    plot_type_str = "Damage";
elseif all(contains(config.fdf_plotting_variables(config.fdf_variable_chosen),"Erosibility"))
    plot_type_str = "Erosibility";
else
    error("Both Damage and Incident Present - Saving Not allowed")
end

if config.query_doing_PRC_analysis == "PRC"

    
    base_path = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Final Article Results\",config.query_doing_PRC_analysis,"\",config.version_number,"\",config.location_considered);
    mkdir(base_path)
    query_iterate_run_number = config.query_iterate;
    global_run_number = Get_Next_Run_Number(base_path+"\counter.txt",query_iterate_run_number);

    folder_save_location = append(base_path,"\",rainfall_type_str,"\Run_Number_",string(global_run_number),"\");
else

    folder_save_location = append("C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Final Article Results\",config.query_doing_PRC_analysis,"\",config.version_number,"\",config.location_considered,"\",plot_type_str,"\");
    global_run_number = -1;
end
end