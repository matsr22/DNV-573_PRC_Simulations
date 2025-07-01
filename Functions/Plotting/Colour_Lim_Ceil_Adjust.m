function y = Colour_Lim_Ceil_Adjust(x)

    % Rounds the top value of the colour bar for cleaner looking figures
    if x == 0
        y = 0;
        return;
    end

    if abs(x) <= 0.05
        % Original logic for small values — nearest 0.005
        order = floor(log10(abs(x)));
        scale = 10^(1 - order);
        x_scaled = x * scale;

        first_digit = floor(x_scaled / 10);
        second_digit = ceil(mod(x_scaled, 10) / 5) * 5;

        if second_digit == 10
            first_digit = first_digit + 1;
            second_digit = 0;
        end

        y_scaled = first_digit * 10 + second_digit;
        y = y_scaled / scale;
    else
        % Round up to 1 significant figure
        order = floor(log10(abs(x)));
        scale = 10^order;
        y = ceil(x / scale) * scale;
    end
end
