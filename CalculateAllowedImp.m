function allowed_imp = CalculateAllowedImp(v_grid,d_grid)
    CPInfo = readtable('Simulation_Data\RENER2024\Coating_Properties.xlsx'); % Protection data information placed here
    
    
    
    
    v_chosen = 120; % This is the value extracted from the 95/95 V-N fit to be used in calculation of the springer constant
    
    % The following code is used to run the RET analysis
    %{
    VNdf = readtable('VN-Data.xlsx');
    X = VNdf{:, 'V'};
    Y = VNdf{:, 'N'};
    Y = Y *1e-6;
    [xConf,yConf,m,b] = regression_confidence(X,Y);
    if ~((min(xConf) < v_chosen) && (v_chosen < max(xConf)))
        error("V_chosen not in range of input")
    end
    Nfit = interp1(xConf,yConf,v_chosen)
    %}
    
    
    importret = load("Simulation_Data\RENER2024\RETData.mat");
    
    d_ret = importret.d_ret;
    m=importret.m;
    b=importret.b;
    Nfit = 1e6*10^(log10(b) - m *log10(v_chosen)); % Coefficent out the front to convert from mm^2 to m^2
    
    
    
    % Constants of the Simulation
    
    % Constants irrespective of turbine/coating design
    
    % These values are for water and are found in the RENER 2024 paper
    
    Z_l = 1484000;
    c_l = 1480;
     
    coatingName = 'RENER_2024'; % Replace this name with the one referenced in Coating_Properties
    coatingDes = CPInfo{:, coatingName};
    temp = num2cell(coatingDes');
    [Z_s,Z_c,c_c,h_c] = temp{:};
    
    % Assume normal incidence of droplets
    alpha = 0;

    % Equations
    
    Z_frac = @(Z_1,Z_2) (Z_1 - Z_2) / (Z_1 + Z_2);
    Theta = @(d) (c_c / c_l) .* ((1 + Z_l / Z_s) ./ (1 + Z_c / Z_s)) .* (2 ./ (1 + Z_l / Z_c)) .* (d ./ h_c);
    K_Bar = @(d) (1-exp(-Theta(d)))./(1-Z_frac(Z_s,Z_c)*Z_frac(Z_l,Z_c));
    HammerPressure = @(v) (Z_l .* v .* cosd(alpha)) ./ (1 + (Z_l ./ Z_c));
    HammerPressure(v_chosen)
    HammerStress = @(d,v) ((1 + Z_frac(Z_s, Z_c)) / (1 - Z_frac(Z_s, Z_c) * Z_frac(Z_l, Z_c))) .* (1- Z_frac(Z_s, Z_c)*((1 + Z_frac(Z_l, Z_c)) / (1 + Z_frac(Z_s, Z_c))).*((1 - exp(-Theta(d))) ./ Theta(d))) .* HammerPressure(v);
    RawStrength = @(S_ec,d) (1+2*K_Bar(d)*abs(Z_frac(Z_s,Z_c)))*S_ec;
    ModifyStress = @(S_c,d) S_c./(1+2*K_Bar(d).*abs(Z_frac(Z_s,Z_c)));
    
    % Calculate the Raw Strength of the Material
    
    springer_inital_modified = HammerStress(d_ret, v_chosen) * ((Nfit*d_ret^2)/8.9)^(1/m);
    
    
    
    springer_raw = RawStrength(springer_inital_modified,d_ret);
    
    % Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 
        
    
    
    
    allowed_imp =(8.9 ./ d_grid.^2) .*( (ModifyStress(springer_raw,d_grid)./ HammerStress(d_grid, v_grid)).^m);

end