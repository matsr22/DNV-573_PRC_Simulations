function result = K_Bar(d, Z_c, Z_l, Z_s, c_c, c_l, h_c)

    result = (1-exp(-Theta(d, Z_c, Z_l, Z_s, c_c, c_l, h_c)))./(1-Z_frac(Z_s,Z_c)*Z_frac(Z_l,Z_c));

end