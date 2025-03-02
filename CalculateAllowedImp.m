function allowed_imp = CalculateAllowedImp(computed_values,v_grid,d_grid)
   
    
    % Using modified strength values at a range of droplet diamteters, calculates the allowed impingements for each bin 
        
    springer_raw = computed_values.springer_raw;
    m = computed_values.m;
    ModifyStress = computed_values.ModifyStress;
    HammerStress = computed_values.HammerStress;
    
    
    allowed_imp =(8.9 ./ d_grid.^2) .*( (ModifyStress(springer_raw,d_grid)./ HammerStress(d_grid, v_grid)).^m);

end