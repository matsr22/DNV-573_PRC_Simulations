function rainfalls = Rainfall_From_Cubic_Meter(n_droplets_air,d_calc)
    % This function returns a vector of rainfall rates corresponding to the number of droplets per cubic meter of each
    % droplet size.
    %
    % This is enabled by assuming the velocity of drops with a certain diameter fall at a specific velocity given by an 
    % analytic function

    % n_droplets_air must be in units of cubic meter, each sampling point should be recorded across the first axis, different diameters across the second axis 
    % d_calc must have compatible dimensions with n_droplets_air, matching the dimensions of the second axis of n_droplets_air


    % Provides the terminal velocity from only the measured values of the droplet size. This equation is a simplified one for the one that takes into account air density
    
    t_v_from_diameters = Terminal_V_From_D(d_calc);

    t_v_from_diameters = (1e3.*t_v_from_diameters)*60*60;

    n_droplets_air = n_droplets_air.*1e-9;

    rainfalls = sum(n_droplets_air.*t_v_from_diameters.*(4/3).*pi.*(d_calc./2).^3,2);

end