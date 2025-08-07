
function binned_data = Bin_Continuous_Parameter(continuous_data,bin_mid_point)
[~, indices] = min(abs(continuous_data - bin_mid_point), [], 2);
binned_data = bin_mid_point(indices)';
end
