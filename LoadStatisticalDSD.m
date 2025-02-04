function [w_bins,d_bins,w_mid,d_mid,matrix] = LoadStatisticalDSD(w_weibull_params,rainfall,w_fidelity,d_fidelity,w_max,d_max)
    

    % This function should return the number of droplets per cubic meter of air per year
    if nargin < 6
        d_max = 8;
    end
    if nargin <5
        w_max = 30;
    end
    if nargin <4
        d_fidelity = 20;
    end
    if nargin < 3 
        w_fidelity = 20;
    end

    [k,c] = w_weibull_params{:};

    w_weibull = @(v) (k/c)*((v./c).^(k-1))*exp(-(v/c).^k);

    W = @(R) 67*R.^0.846;
    V = @(D) (1/6)*pi*(D.^3);
    a = @(R) 1.3*R.^0.232;
    k_B = 2.25;

    best = @(D,R) (W(R)./V(D)) * ((k_B*D.^(k_B-1))/(a(R).^k_B))*exp(-(D/a(R)).^k_B);

    if length(rainfall) == 3
        total_rainfall = rainfall(1);
        sigma_r = rainfall(2);
        mean_r = rainfall(3);
    else 
        total_rainfall = sum(rainfall);
        sigma_r = std(log(rainfall));
        mean_r = mean(log(rainfall));
    end

    rainfall_fdf = @(R) (total_rainfall ./ (R .* sigma_r .* sqrt(2 * pi))).*exp(-0.5 * ((log(R) - mean_r) ./ sigma_r).^2 - (mean_r + (sigma_r.^2) / 2));

    combined_rain_best = @(D,R) rainfall_fdf(R).*best(D,R);

    N_0 = @(D) integral(@(R) combined_rain_best(R,D),0,inf);

    droplet_fdf = @(v,D) w_weibull(v).*N_0(D);

    w_bins = linspace(0,w_max,w_fidelity);
    d_bins = linspace(0,d_max,d_fidelity);
    w_mid = 0.5*w_bins(1:(length(w_bins)-1)).*w_bins(2:end);
    d_mid = 0.5*d_bins(1:(length(d_bins)-1)).*d_bins(2:end);


    matrix = zeros((length(d_bins)-1),(length(w_bins)-1));
    for i = 1:(length(d_bins)-1)
        for x = 1:(length(w_bins)-1)
            matrix(i,x) = integral2(@(v,D) droplet_fdf(v,D),w_bins(x),w_bins(x+1),d_bins(i),d_bins(i+1));
        end
    end
end