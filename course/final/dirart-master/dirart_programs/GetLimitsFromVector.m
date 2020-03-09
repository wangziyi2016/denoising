function limits = GetLimitsFromVector(vec)
%
%
%
limits = [vec(1) vec(end)];
if vec(end)<vec(1)
	limits = [vec(end) vec(1)];
end

	