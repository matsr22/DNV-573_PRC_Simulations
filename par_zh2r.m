function r = par_zh2r(coeff,zh)
% PAR_ZH2R converts a vector of reflectivity ZH (dBZ) into a vector of rainfall intesity R(mm/h)
% using a standard R=COEFF(1)*Zh.^COEFF(2) (Zh in mm6/m3)
%Utilizzo:
% r = par_zh2r(coeff,zh);
%
% Input
%   zh      : [Nx1] vector containing Zh in dBz
%   coeff   : coefficients of R=COEFF(1).^(Zh.*COEFF(2)) (Zh in mm6/m3)
%          
% Parametri in uscita:
%
%   r       : [Nx1] vector containing R in mm/h
%
% 10 march 2010

r = coeff(1)*10.^(zh*0.1*coeff(2));

end