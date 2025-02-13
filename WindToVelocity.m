function velocity = WindToVelocity(windspeed,path,radius)

    WTDF = load(path);
    W_sp = WTDF.windSpeed;
    omega = WTDF.omega;

    interp_omega = interp1(W_sp,omega,windspeed); % Could change the interpolation method later

    velocity = radius*interp_omega;
end