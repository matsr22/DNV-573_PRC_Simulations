function terminal_velocity = Terminal_V_From_D(diameter)
% Gives the terminal velocity as predicted by ROADWORKS - find the source -
% a function of the droplet size
%
% diameter - the droplet diameter in [mm]
% terminal_velocity - the terminal velocity in [m/s]
terminal_velocity = 9.65 - 10.3.*exp(-0.6.*diameter);
end