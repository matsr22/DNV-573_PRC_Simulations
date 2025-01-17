function theta = Theta(d, Z_c, Z_l, Z_s, c_c, c_l, h_c)
    theta = (c_c / c_l) .* ((1 + Z_l / Z_s) / (1 + Z_c / Z_s)) .* (2 / (1 + Z_l / Z_c)) .* (d / h_c);
end