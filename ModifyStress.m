function S_ec = ModifyStress(S_c,d, Z_c, Z_l, Z_s, c_c, c_l, h_c)
    
    S_ec = S_c./(1+2*K_Bar(d, Z_c, Z_l, Z_s, c_c, c_l, h_c).*abs(Z_frac(Z_s,Z_c)));


end