function Gen_PRC_LaTeX(config,uncurt_result,rainfall_result,ideal_result,rainfall_prc,ideal_prc)


uncurt_damage = sum(uncurt_result.damage_matrix,"all");
prc_damage = sum(rainfall_result.damage_matrix,"all");

data_quantity_days = uncurt_result.data_quantity_days;

uncurt_life_y = (data_quantity_days*24*(1/uncurt_damage)) * 0.000114155;
prc_life_y = rainfall_result.incubation_hours * 0.000114155;
ideal_life_y  = ideal_result.incubation_hours * 0.000114155;
percent_increase_parameter = 100*(abs(prc_life_y-uncurt_life_y)/uncurt_life_y); 
percent_increase_ideal = 100*(abs(ideal_life_y-uncurt_life_y)/uncurt_life_y);


data_quant_param_curt = rainfall_prc.data_quantity_curtailed;
data_quant_ideal_param = ideal_prc.data_quantity_curtailed;

AEP_uncurt = uncurt_result.AEP;
AEP_param = rainfall_result.AEP;
AEP_ideal = ideal_result.AEP;

AEP_p_param = 100*abs(AEP_param-AEP_uncurt)/AEP_uncurt;
AEP_p_ideal = 100*abs(AEP_ideal-AEP_uncurt)/AEP_uncurt;

wind_velocities = uncurt_result.wind_velocities;
percent_turbine_operational = 100* length(wind_velocities(wind_velocities>=3 & wind_velocities<=25))/length(wind_velocities);
percent_curtail_enabled_param = (data_quant_param_curt/ length(wind_velocities(wind_velocities>=3 & wind_velocities<=25)))*100;
percent_curtail_enabled_ideal = (data_quant_ideal_param/ length(wind_velocities(wind_velocities>=3 & wind_velocities<=25)))*100;

if config.use_best_distribution_PRC
    curtailing_type = "Best";
else
    curtailing_type = "Measured";
end

if config.curtailing_criteria_chosen == 6
    error("Primary Curtailing Type can not be damage")
elseif config.curtailing_criteria_chosen == 1
    param_lower = config.curtailing_lower_criteria; % Dmass based curtailing
    curtailing_type = strjoin(curtailing_type,"Dmass");
elseif config.curtailing_criteria_chosen == 3
    param_lower = config.curtailing_rainfall_lower;
    curtailing_type = strjoin(curtailing_type,"Rainfall");
else
    error("Curtailing Type Not yet setup")
end

Curtailing_Metric = ["Curtailing_Type","P_Cut(No-PRC)","Life [yr] (No-PRC)","P Life Increase (No-PRC)","AEP Loss % (No-PRC)","% Turbine Active (No-PRC)","% PRC Enabled (No-PRC)",...
    "LaTeX (No-PRC)",...
    "P_Cut(Parameter)","Life [yr] (Parameter)","P Life Increase (Parameter)","AEP Loss % (Parameter)", "% Turbine Active (Parameter)","% PRC Enabled (Parameter)",...
    "LaTeX (Parameter)",...
    "P_Cut(Ideal)","Life [yr] (Ideal)","P Life Increase (Ideal)","AEP Loss % (Ideal)", "% Turbine Active (Ideal)","% PRC Enabled (Ideal)",...
    "LaTeX (Ideal)"];


Data_Metric = [curtailing_type,"-",uncurt_life_y,0,0,percent_turbine_operational,0,...
    "=TEXTJOIN("" & "", TRUE, OFFSET(INDIRECT(ADDRESS(ROW(), COLUMN())), -6, 0, 6, 1)) & "" \\""",...
    param_lower,prc_life_y,percent_increase_parameter,AEP_p_param,percent_turbine_operational,percent_curtail_enabled_param,...
    "=TEXTJOIN("" & "", TRUE, OFFSET(INDIRECT(ADDRESS(ROW(), COLUMN())), -6, 0, 6, 1)) & "" \\""",...
    "-",ideal_life_y,percent_increase_ideal,AEP_p_ideal,percent_turbine_operational,percent_curtail_enabled_ideal,...
    "=TEXTJOIN("" & "", TRUE, OFFSET(INDIRECT(ADDRESS(ROW(), COLUMN())), -6, 0, 6, 1)) & "" \\"""...
    ];

for i = 1:length(Data_Metric)
    val = str2double(Data_Metric(i));
    if ~isnan(val)
        Data_Metric(i) = sprintf('%.3g', val);
    end
end

Curtailing_Metric = Curtailing_Metric(:); % Convert to column vectors
Data_Metric = Data_Metric(:);

path = fileparts(fileparts(fileparts(uncurt_result.folder_save_location)))+"\"+config.location_considered+"_LaTeX_Table"+"_"+config.version_number+".xlsx";

Write_Excel_Table(Curtailing_Metric,Data_Metric,path,uncurt_result.global_run_number);

close all
end