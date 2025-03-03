function allowed_imp = CalculateAllowedImpingements(input_values,v_grid,d_grid)
    % For the droplet and velocity pairs provided by v_grid and d_grid, this function determines how many impingements are allowable before damage occurs
    
    % Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 
        
    raw_springer = input_values.raw_springer;
    m = input_values.m;
    ModifiedStrength = input_values.ModifiedStrength;
    HammerStress = input_values.HammerStress;
    
    
    allowed_imp =(8.9 ./ d_grid.^2) .*((ModifiedStrength(raw_springer,d_grid)./ HammerStress(d_grid, v_grid)).^m);

end