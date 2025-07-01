function Plot_Damages_D(damages,d_calc,fileName)
% This function plots the damage as a function of the diameter class

% Assumes different sampling points across the first axis, diameters on the
% second
damages = sum(damages,1);

fig =figure;
plot(d_calc,damages,'o-','MarkerSize',3,'MarkerEdgeColor', 'k','MarkerFaceColor', 'k','Color', 'k','LineWidth', 1.5);
xlabel("Droplet Diameter [mm]")
ylabel("n_s/N_s")

box on;
grid on;

Save_Fig_Validated(fig, "C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Damage_Site_Droplet_Comparisons\Unnormalised"+fileName);
end