function [velocity,power] = WindToBladeVelocity(input_windspeed,radius,turbine_power,curtailing_percentage,curtailing_locations)
    
    if ~(turbine_power == "15MW") || nargin<4 % PRC only currently coded for 15MW turbine
    WTDF = load(append("Simulation_Data\Turbine_Curves\Turbine_Data_",turbine_power,".mat"));
    W_sp = WTDF.windSpeed;
    omega = WTDF.omega;
    power = 0;

    interp_omega = interp1(W_sp,omega,input_windspeed); % Could change the interpolation method later

    velocity = radius*interp_omega;
    else
    
     [standard_turbine_wind, standard_turbine_omega,standard_turbine_power] = load_curves(append("Simulation_Data\Turbine_Curves\Uncurtailed_",string(turbine_power),".mat"));


     interp_standard_omega = interp1(standard_turbine_wind,standard_turbine_omega,input_windspeed); % Could change the interpolation method later
     power = interp1(standard_turbine_wind,standard_turbine_power,input_windspeed);
     velocity = interp_standard_omega*radius;
     
     [curtailed_turbine_wind, curtailed_turbine_omega,curtailed_turbine_power] = load_curves(append("Simulation_Data\Turbine_Curves\Curtailed_",string(curtailing_percentage),"ms_",turbine_power,".mat"));

     curtailed_omega = interp1(curtailed_turbine_wind,curtailed_turbine_omega,input_windspeed);
     curtailed_power = interp1(curtailed_turbine_wind,curtailed_turbine_power,input_windspeed);
     curtailed_velocity = curtailed_omega*radius;
     velocity(curtailing_locations) = curtailed_velocity(curtailing_locations);
     power(curtailing_locations) = curtailed_power(curtailing_locations);

     
    end
end

 
function [wind,omega,power] = load_curves(path)
structure =  load(path);

wind = structure.windSpeed;
omega = structure.omega;
power = structure.power;

end