function velocity = WindToBladeVelocity(input_windspeed,radius)

    WTDF = load("Simulation_Data\RENER2024\wind_omega_5MW.mat");
    W_sp = WTDF.windSpeed;
    omega = WTDF.omega;

    interp_omega = interp1(W_sp,omega,input_windspeed); % Could change the interpolation method later

    velocity = radius*interp_omega;
end