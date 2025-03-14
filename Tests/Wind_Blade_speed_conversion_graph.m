% Plots a quick graph of the wind speed against the blade speed for strip 6

wind_speeds = linspace(3,35);
v_mid = WindToBladeVelocity(wind_speeds,60.8) ;

plot(wind_speeds,v_mid);

xlabel("Wind Speed (m/s)");
ylabel("Blade Speed (m/s)");
grid("on")