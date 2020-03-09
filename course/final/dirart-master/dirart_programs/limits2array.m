function limitsout = limits2array(limits)
%
%
%
limitsout = limits;
if isstruct(limits)
	limitsout = limits.ys';
	limitsout(2,1:2) = limits.xs';
	limitsout(3,1:2) = limits.zs';
end
