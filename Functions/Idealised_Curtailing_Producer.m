% Produce Idealised AEP / Lifetime Graph

multipliers = logspace(log10(1.01),log10(20),40);
AEPs = [];
lifetimes = []; % Hours

for exterior_index = 1:length(multipliers)
    lifetime_extention_multiplier = multipliers(exterior_index);
    Simulation_TimeSeries;
    lifetimes(exterior_index) =strip_hours(strip_index);
    AEPs(exterior_index) = AEP_curt;
end

fig = figure;
plot(lifetimes,AEPs)
xlabel("Lifetime [h]")
ylabel("AEP [MWh]")

