function tipSpeed = WindToTip(windspeed,path)

    WTDF = readtable(path);
    W_sp = WTDF{:, 'Wind_Speed'};
    T_sp = WTDF{:,'Tip_Speed'};

    tipSpeed = interp1(W_sp,T_sp,windspeed); % Could change the interpolation method later

end