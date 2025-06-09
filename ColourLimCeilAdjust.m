function y = ColourLimCeilAdjust(x)
    if x == 0
        y = 0;
        return;
    end
    
    % Order of magnitude
    order = floor(log10(abs(x)));
    
    % Scale number so that first 2 significant digits are at integer level
    scale = 10^(1 - order);
    x_scaled = x * scale;

    % Get the first two significant digits
    first_digit = floor(x_scaled / 10);
    second_digit = ceil(mod(x_scaled, 10) / 5) * 5;

    if second_digit == 10
        first_digit = first_digit + 1;
        second_digit = 0;
    end

    y_scaled = first_digit * 10 + second_digit;

    % Scale back to original magnitude
    y = y_scaled / scale;
end