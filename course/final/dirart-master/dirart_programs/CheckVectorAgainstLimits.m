function [x1,x2] = CheckVectorAgainstLimits(x1,x2,limits)
%
%
%

limits = GetLimitsFromVector(limits);
xs = GetLimitsFromVector([x1 x2]);
x1 = xs(1);
x2 = xs(2);
x1 = max(x1,limits(1));
x2 = min(x2,limits(2));



