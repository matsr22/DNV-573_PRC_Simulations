function S_c = RawStrength(S_ec,d, Z_c, Z_l, Z_s, c_c, c_l, h_c)
    
    S_c = (1+2*K_Bar(d, Z_c, Z_l, Z_s, c_c, c_l, h_c)*abs(Z_frac(Z_s,Z_c)))*S_ec;


end

