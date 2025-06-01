function [velocity,power] = WindToBladeVelocity(input_windspeed,radius,turbine_power)

    WTDF = load(append("Simulation_Data\Turbine_Curves\Turbine_Data_",string(turbine_power),".mat"));
    W_sp = WTDF.windSpeed;
    omega = WTDF.omega;
    power = 0;

    interp_omega = interp1(W_sp,omega,input_windspeed); % Could change the interpolation method later

    velocity = radius*interp_omega;
end

% 
% function [velocity,power] = WindToBladeVelocity(input_windspeed,radius,turbine_power,curtailing_locations,curtailing_windspeed)
% 
%     [standard_turbine_wind, standard_turbine_omega,standard_turbine_power]
%     =
%     load_curves(append("Simulation_Data\Turbine_Curves\",string(turbine_power),"\standard.txt"));
% 
% 
%     interp_standard_omega = interp1(standard_turbine_wind,standard_turbine_omega,input_windspeed); % Could change the interpolation method later
%     power =
%     interp1(standard_turbine_wind,standard_turbine_power,input_windspeed);
%     velocity = interp_standard_omega*radius;
%     if nargin>3
%         [curtailed_turbine_wind, curtailed_turbine_omega,curtailed_turbine_power] = load_curves(append("Simulation_Data\Turbine_Curves\",string(turbine_power),"\",string(curtailing_windspeed),".txt"));
% 
%         curtailed_omega = interp1(curtailed_turbine_wind,curtailed_turbine_omega,input_windspeed);
%         curtailed_power = interp1(curtailed_turbine_wind,curtailed_turbine_power,input_windspeed);
%         curtailed_velocity = curtailed_omega*radius;
% 
%         velocity(curtailing_locations) = curtailed_velocity(curtailing_locations);
%         power(curtailing_locations) = curtailed_power(curtailing_locations);
% 
%     end
% 
% end
% 
% function [wind_speeds,omegas, powers] =  load_curves(path)
%     This function gets from a txt containing turbine curves, extracts the
%     rotor speeds [rad/s] and power [W] for specific wind speeds [m/s]
% 
%     Load in Blade Speed and Pitch from previously ran control simulation
%     fid = fopen(path, 'r');
%     header = fgetl(fid);  % Skip the header line
%     data = textscan(fid, '%f %f %f %f %f %f');
%     fclose(fid);
% 
%     wind_speeds = data{1}';
%     omegas = data{5}';
%     powers = data{2}';
% 
%     omegas = omegas*pi/30; % Convert from rpm
%     powers = powers*1e3; % Convert to W
% 
%     Add data before and after so as to ensure cut in and cut out are
%     mesaured correctly
% 
%     wind_speeds = [0 wind_speeds(1)-0.001 wind_speeds wind_speeds(end)+0.001 300];
%     omegas = [0 0 omegas 0 0];
%     powers = [0 0 powers 0 0];
% end