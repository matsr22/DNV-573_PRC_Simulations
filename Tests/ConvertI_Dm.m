

addpath(genpath('..\Functions\'))
addpath(genpath('..\Simulation_Data\'))
addpath(fileparts(pwd));

config = Config();

query_Dmass = 0.7;

[~, d_calc,d_bins,~] = Unpack_Wind_Rain_Data("C:\Users\matth\Documents\MATLAB\DNV matlab code\Simulation_Data\Lancaster\10min_data_filt.mat",true,false); 

rainfall_reference = logspace(-3,0.6990,1000);
produced_best_dist = Construct_Best_Distributions(rainfall_reference,d_calc,d_bins);

Dmasses = Calculate_Dmass(produced_best_dist,d_calc,d_bins);

interp1(Dmasses,rainfall_reference,1.33637)
% plot(Dmasses, rainfall_reference,'LineWidth',2)
% 
% xlabel("D_{m} (Best) [mm]", 'Interpreter', 'tex')
% ylabel("Rainfall [mm/h]")
% ylim([0 5])
% legend("Best","Location","northwest")