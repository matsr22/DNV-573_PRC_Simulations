function m_w_d = Calculate_Dmass(n_droplets_air,d_calc,d_bins)
% Uses the number of droplets per cubic meter of air per mm width to the
% 4th moment of diameter integrated over the 3rd moment of diameter to
% produce an assessment of the overall erosivity of the rainfall event

% The droplet diameter must be on the second axis

% n_droplets_air is in units of 1/m^3

% d_calc,d_bins in units of mm

d_widths = d_bins(2:end)-d_bins(1:end-1);

m_w_d = sum((n_droplets_air./d_widths).*d_calc.^4,2)./sum((n_droplets_air./d_widths).*d_calc.^3,2);
end

