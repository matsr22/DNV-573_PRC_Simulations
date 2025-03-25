function velocity = WindToBladeVelocity(input_windspeed,radius,turbine_power)
    
    WTDF = load(append("Simulation_Data\RENER2024\Turbine_Data_",string(turbine_power),"MW.mat"));
    W_sp = WTDF.windSpeed;
    omega = WTDF.omega;

    interp_omega = interp1(W_sp,omega,input_windspeed); % Could change the interpolation method later

    velocity = radius*interp_omega;
end