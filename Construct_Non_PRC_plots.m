close all;

addpath(genpath('Functions\'))

%
% Configuration of the Simulation
%

config = Default_Config;

config.version_number = "V_1";
config.normalise_plot = 1;

plotting_variables = [1];

Produce_Plots(plotting_variables,config);

close all;

plotting_variables = [3 7];

Produce_Plots(plotting_variables,config);

close all;

plotting_variables = [5];

Produce_Plots(plotting_variables,config,false,true);

close all;



plotting_variables = [2 4 8];

Produce_Plots(plotting_variables,config);

plotting_variables = [6];

Produce_Plots(plotting_variables,config,false);

close all;


function Produce_Plots(plotting_variables,config,use_best,clear_between)
if nargin <3
    use_best = true;
end

if nargin <4
    clear_between = false;
end

for i = plotting_variables

    config.fdf_variable_chosen=i;

    config = Set_Lampedusa(config);

    
    
    if use_best
    config.use_best_distribution_simulation = true;
    Main_Algorithm(config);
    end
    config.use_best_distribution_simulation = false;
    Main_Algorithm(config);

    if clear_between
        close all;
    end
    
    config = Set_Lancaster(config);
    
    if use_best
    config.use_best_distribution_simulation = true;
    Main_Algorithm(config);
    end
    config.use_best_distribution_simulation = false;
    Main_Algorithm(config);

    if clear_between
        close all;
    end

    config = Set_North_Sea(config);
    Main_Algorithm(config);

    close all;

end

end