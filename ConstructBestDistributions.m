function [n_droplets_air] = ConstructBestDistributions(input_table,d_calc,d_bins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    rainfalls = input_table.rainfall_mm_hr; % Gives the rainfall in mm/hr for each interval

    efficency_threshold = 1e-5; % Sets the threshold at which below this, calculating the integral is ignored to save computation power without affecting the result
    

    % These following equations fully describe the best distribution

    W = @(R) 67*R.^0.846; % Rainfall is input in mm_hr in this context
    V = @(D) (1/6)*pi*(D.^3);
    a = @(R) 1.3*R.^0.232;
    k_B = 2.25;
    best_distribution = @(D,R) (W(R)./V(D)) .* ((k_B*D.^(k_B-1))./(a(R).^k_B)).*exp(-(D./a(R)).^k_B);

    % Initialise the Best Distribution
    n_droplets_air = zeros(length(rainfalls),length(d_calc));

    % Loop through every rainfall, assigning a best dsd to each one
    for x = 1:length(rainfalls)
        best_set_rainfall = @(D) best_distribution(D,rainfalls(x)); % Produces the equation in terms of just D so can be single variable integrated
        if rainfalls(x) == 0 % Sets to 0 for 0 rainfall values
            n_droplets_air(x,:) = 0;
        else
            % Integrates for each droplet bin to calculate how many
            % droplets best predicts
            for u = 1:length(d_calc)
                integral_estimator = best_set_rainfall(d_calc(u))*(d_bins(u+1)- d_bins(u+1)); % Estimates the value of the number of droplets - if sufficently low, ignores to save a little on computing power - no effect on result to 5.s.f
                if(integral_estimator < efficency_threshold)
                    n_droplets_air(x,u) = integral(best_set_rainfall,d_bins(u),d_bins(u+1));
                else
                    n_droplets_air(x,u) = 0;
                end
            end   
        end
    end
end