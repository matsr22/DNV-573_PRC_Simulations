function result = HammerStress(d, v, Z_c, Z_l, Z_s, alpha, c_c, c_l, h_c)
    % _summary_
    %
    % Args:
    %     d (float or array<float>): The droplet diameter(s) of an equivalent volume sphere impinging on the blade. Given in mm
    %     v (float or array<float>): The droplet velocity(s). Given in m/s
    %     Z_c (float): The acoustic impedance of the coating. Given in kg/(m^2 s)
    %     Z_l (float): The acoustic impedance of the liquid (water for rain droplets). Given in kg/(m^2 s)
    %     Z_s (float): The acoustic impedance of the substrate. Given in kg/(m^2 s)
    %     alpha (float): The angle of incidence for the droplet upon the
    %     blade. Given in degrees
    %     c_c (float): Speed of sound in the coating. Given in m/s
    %     c_l (float): Speed of sound in the liquid. Given in m/s
    %     h_c (float): Thickness of the coating. Given in mm
    % Returns:
    %     _type_: _description_

    result = ((1 + Z_frac(Z_s, Z_c)) ./ (1 - Z_frac(Z_s, Z_c) .* Z_frac(Z_l, Z_c))) .* (1- Z_frac(Z_s, Z_c).*((1 + Z_frac(Z_l, Z_c)) ./ (1 + Z_frac(Z_s, Z_c))).*((1 - exp(-Theta(d, Z_c, Z_l, Z_s, c_c, c_l, h_c))) ./ Theta(d, Z_c, Z_l, Z_s, c_c, c_l, h_c))) .* HammerPressure(Z_l, Z_c, alpha, v);
end




function result = HammerPressure(Z_l, Z_c, alpha, v)
    % _summary_
    %
    % Args:
    %     Z_c (float): The acoustic impedance of the coating. Given in kg/(m^2 s)
    %     Z_l (float): The acoustic impedance of the liquid (water for rain droplets). Given in kg/(m^2 s)
    %     alpha (float): The angle of incidence for the droplet upon the blade. Given in degrees
    %     v (float or array<float>): The droplet velocity(s). Given in m/s

    result = (Z_l .* v .* cosd(alpha)) ./ (1 + (Z_l ./ Z_c));
end






