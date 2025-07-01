function input_values = Get_Springer_Strength(coatingName)
    
    % This code sets up the springer simulation so that when running, the minimum number of calculations have to be performed

    % OUTPUTS:

    % Returns an array of constants required for the calculation of allowed
    % impingements before faliure - seperate function. For Units refer to
    % the DNV-573 standard

    % Currently the Springer strength is directly input as otherwise this
    % has to be derived from a full statistical analysis of RET data
    
    % Constants of the Simulation

    %Import the material
    coating_table = readtable("Simulation_Data\Coating_Properties.xlsx");
    specific_dataset = coating_table.(coatingName);
    
    % These values are for water
    
    Z_l = 1484000;%Impedance
    c_l = 1480;%Speed of Sound
     
    % The following are turbine specific
    % (All in base SI units)
    % Impedance of substrate + coating
    Z_s = specific_dataset(1);
    Z_c = specific_dataset(2);

    % Speed of sound in coating
    c_c = specific_dataset(3);
    % Thickness of coating
    h_c = specific_dataset(5); % Index 4 is the speed of sound in the substrate, not used
    
    % Assume normal incidence of droplets
    alpha = 0;

    % Equations
    
    Z_frac = @(Z_1,Z_2) (Z_1 - Z_2) / (Z_1 + Z_2);
    Theta = @(d) (c_c / c_l) .* ((1 + Z_l / Z_s) ./ (1 + Z_c / Z_s)) .* (2 ./ (1 + Z_l / Z_c)) .* (d ./ h_c);
    K_Bar = @(d) (1-exp(-Theta(d)))./(1-Z_frac(Z_s,Z_c)*Z_frac(Z_l,Z_c));
    HammerPressure = @(v) (Z_l .* v .* cosd(alpha)) ./ (1 + (Z_l ./ Z_c));
    HammerStress = @(d,v) ((1 + Z_frac(Z_s, Z_c)) / (1 - Z_frac(Z_s, Z_c) * Z_frac(Z_l, Z_c))) .* (1- Z_frac(Z_s, Z_c)*((1 + Z_frac(Z_l, Z_c)) / (1 + Z_frac(Z_s, Z_c))).*((1 - exp(-Theta(d))) ./ Theta(d))) .* HammerPressure(v);
    RawStrength = @(S_ec,d) (1+2*K_Bar(d)*abs(Z_frac(Z_s,Z_c)))*S_ec;
    ModifiedStrength = @(S_c,d) S_c./(1+2*K_Bar(d).*abs(Z_frac(Z_s,Z_c)));

    % % Used in absence of the springer strength
    [m,raw_springer] = GetSpringerConstantFromFile(coatingName);
    

    input_values = struct('raw_springer', raw_springer, 'm', m, ...
        'ModifiedStrength', ModifiedStrength, 'HammerStress', HammerStress);
end



function [m,raw_springer] = GetSpringerConstantFromFile(coatingName)
    strength_table = readtable("Simulation_Data\Coating_Strength_Data.xlsx");
    specific_dataset = strength_table.(coatingName);
    m = specific_dataset(1);
    raw_springer = specific_dataset(2);
    
end

% FOLLOWING TWO FUNCTIONS UNUSED AND UNFINISHED - REQUIRED ONLY IF NO RAW
% STRENGTH VALUE CAN BE OBTAINED

function [a,m,d_ret,v_ret] = Get_Ret_Data(coatingName)
    ret_table = readtable("Simulation_Data\RET_Data.xlsx");
    specific_dataset = ret_table.(coatingName);
    a = specific_dataset(1);
    m = specific_dataset(2);
    d_ret = specific_dataset(3);
    v_ret = specific_dataset(4);
end


function [m,raw_springer] = CalculateSpringerConstant(HammerStress,RawStrength,coatingName)
% Following lines Calculate the Raw Strength of the Material - if unknown

% Note this code may not entirely complete - UPDATE 25/03/2025 - It is
% possible the RET values in the paper were simply incorrect. 

% The full statistical approach must be used to calculate the raw_springer
% constant, as it is a function of the 95% confidence band




[a,m,d_ret,v_ret] = Get_Ret_Data(coatingName);


Nfit = a *v_ret^(-m);


springer_inital_modified = HammerStress(d_ret, v_ret) * (Nfit*(1e3*d_ret^2)/8.9)^(1/m);



raw_springer = RawStrength(springer_inital_modified,d_ret);
end