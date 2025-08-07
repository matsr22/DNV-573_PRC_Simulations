classdef Config < handle
    properties
        % WIND OPTIONS
        use_extrapolated_wind_data = true
        use_exact_w_s = true % Controls if exact wind speed is used or wind is binned
        
        % TURBINE OPTIONS
        turbine_used = "15MW"
        coating_used = 'ThreeM'
        consider_all_strips = false
        
        % RAINFALL OPTIONS
        use_filtered_data = true
        consider_terminal_velocities = true
        use_measured_terminal_velocites = false
        use_best_distribution_simulation = false
        ommit_first_droplet_class = true
        ommit_lowest_rainfall_rates = false
        
        % DATASET OPTIONS
        location_considered = "UNSET"
        DT = 10
        fdf_variable_chosen = []
        normalise_plot = 1
        fdf_plotting_variables = ["Droplet_Diameter_Damage", ...
                                  "Droplet_Diameter_Incident", ...                           
                                  "Mass_Weighted_Diameter_Damage", ...
                                  "Mass_Weighted_Diameter_Incident", ...
                                  "Mass_Weighted_Diameter_Erosibility",...
                                  "Rainfall_Damage", ...
                                  "Rainfall_Incident", ...
                                  "Rainfall_Erosibility",...
                                  "Median_Diameter_Damage", ...
                                  "Median_Diameter_Incident",...
                                  "Median_Diameter_Erosibility"]
        
        % PRECIPITATION REACTIVE CONTROL (PRC)
        enable_PRC = false
        curtailing_wind_speed = 9
        use_best_distribution_PRC = false
        curtailing_criteria = ["DMass", "DMedian", "Rainfall", "Dm_Rainfall", "D0_Rainfall", "Damage"]
        curtailing_criteria_chosen = 3
        
        curtailing_lower_criteria = "-"
        curtailing_upper_criteria = "-"
        
        curtailing_wind_speed_lower = 9
        curtailing_wind_speed_upper = 25
        
        curtailing_rainfall_lower = "-";
        curtailing_rainfall_upper = "-";
        
        damage_number_elements_curtail = 10;
        
        % PLOTTING
        plot_fdf = true
        plot_hor_lim_line = false;
        
        % GENERAL METADATA
        query_doing_PRC_analysis = "Non-PRC"
        version_number = "DEFAULT"

        global_damage;

        query_iterate = false; % Determines if the global run number variable is iterated or not
    end

    methods
        function self = Config()
            % Constructor
        end

        function Set_Location(self,location_name)
            if location_name == "Lancaster" || location_name == "Lampedusa"
                self.use_best_distribution_simulation = false;
            elseif location_name == "North_Sea"
                self.use_best_distribution_simulation = true; % We can only simulate with the best distribution for the north sea 
            else
                error("Location Name Not Valid")
            end
            self.location_considered = location_name;
        end
        
    end
end