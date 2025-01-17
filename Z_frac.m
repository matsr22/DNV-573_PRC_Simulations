function result = Z_frac(Z_1, Z_2)
    % The Impedance Fraction between two Impedances.
    %
    % Args:
    %     Z_1 (float): Impedance 1
    %     Z_2 (float): Impedance 2
    %
    % Returns:
    %     _type_:

    result = (Z_1 - Z_2) / (Z_1 + Z_2);
end