function [xConfidence, yConfidence,m,b] = regression_confidence(Xdata, Ydata, confidence, fidelity)
    if nargin < 3
        confidence = 0.95;
    end
    if nargin < 4
        fidelity = 200;
    end

    Xdata = log10(Xdata);
    Ydata = log10(Ydata);

    % Perform linear regression
    coeffs = polyfit(Xdata, Ydata, 1);
    slope = coeffs(1);
    intercept = coeffs(2);

    % Statistical terms
    XMean = mean(Xdata);
    k = length(Xdata); % Number of elements in Xdata
    SDMX = sum((Xdata - XMean).^2);
    Variance = sum((Ydata - (intercept + Xdata * slope)).^2) / (k - 2);
    Fval = finv(confidence, 2, k - 2);

    % Generate confidence curve
    xConfidence = linspace(min(Xdata), max(Xdata), fidelity);
    xModifier = sqrt(2 * Fval * Variance) * sqrt((1 / k) + ((xConfidence - XMean).^2) / SDMX);
    yConfidence = intercept + slope * xConfidence - xModifier;

    xConfidence = 10.^xConfidence;
    yConfidence = 10.^yConfidence;
    m = -slope;
    b=intercept;
end