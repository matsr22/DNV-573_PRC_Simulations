function Vector_To_LaTeXcode(vector)
    % Converts a row vector to a LaTeX table row string
    % Numbers are given to 5 significant figures
    % Uses scientific notation for values outside [1e-4, 1e4]
    
    formatted_vals = arrayfun(@Format_Number, vector, 'UniformOutput', false)
    latex_string = strjoin(formatted_vals, ' & ');
    latex_string = [latex_string, ' \\']; % Add LaTeX newline character
    disp(latex_string)
end

function num_to_rounded_string = Format_Number(num)
    if abs(num) >= 1e-4 && abs(num) <= 1e4
        num_to_rounded_string = sprintf('%.5g', num); % Standard notation for numbers in range
    else
        exponent = floor(log10(abs(num))); % Get exponent
        base = num / 10^exponent; % Normalize to scientific notation
        num_to_rounded_string = sprintf('$%.5g \\times 10^{%d}$', base, exponent); % Ensure proper LaTeX formatting
    end
end