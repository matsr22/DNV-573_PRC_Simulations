function tipSpeed = WindToTip(windspeed,path)

    WTDF = readtable(path);
    W_sp = WTDF{:, 'Wind speed [m/s]'};
    T_sp = WTDF{:,'Tip speed [m/s]'};

    tipSpeed = interp1(W_sp,T_sp,windspeed); % Could change the interpolation method later

end