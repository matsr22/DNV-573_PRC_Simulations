function [xConfidence, yConfidence,m,b] = regression_confidence(Xdata, Ydata, confidence, fidelity)
    % Returns the V-N curve fit with a default 95/95 statistical approach. Returns in the non-log domain. Based on the statistical approach given by ASTM 739
    %
    % Args:
    %   Xdata, Ydata (float vector): data from the V-N curve with V on the X axis and N on the Y
    %   Confidence: The confidence any points will lie above the curve provided
    %   fidelity: The number of points the output curve is defined as
    %   
    % Returns:
    %   XConfidence,Yconfidence (float vectors): The output curve, with points to be interpolated
    %   m,b: The linear fitting coefficents of the log log data. In the form log(N) = b-m*log*(V)
    %
    %
    %

    if nargin < 3
        confidence = 0.95;
    end
    if nargin < 4
        fidelity = 200;
    end

    % Switch to log domain
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
    b=exp(intercept);
end


% The following code is used to run the RET analysis
%{
        VNdf = readtable('VN-Data.xlsx');
        X = VNdf{:, 'V'};
        Y = VNdf{:, 'N'};
        Y = Y *1e-6;
        [xConf,yConf,m,b] = regression_confidence(X,Y);
        if ~((min(xConf) < v_chosen) && (v_chosen < max(xConf)))
            error("V_chosen not in range of input")
        end
        Nfit = interp1(xConf,yConf,v_chosen)
%}