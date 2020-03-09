function [der] = select_der(der_minus, der_plus)

if size(der_minus) ~= size(der_plus)
    error('plus, minus derivative vectors need to be of equal length!');
end

der = sign(der_minus) .* min( abs(der_minus), abs(der_plus) ) .* ((der_minus .* der_plus)>0);

return;


