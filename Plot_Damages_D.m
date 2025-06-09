function Plot_Damages_D(damages,d_calc,fileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
damages = sum(damages,1);

fig =figure;
plot(d_calc,damages,'o-','MarkerSize',3,'MarkerEdgeColor', 'k','MarkerFaceColor', 'k','Color', 'k','LineWidth', 1.5);
xlabel("Droplet Diameter [mm]")
ylabel("n_s/N_s")

box on;
grid on;

savefig(fig, "C:\Users\matth\Documents\MATLAB\DNV matlab code\Plots\Damage_Site_Droplet_Comparisons\Unnormalised"+fileName);
end