function idxes = GetDimensionIdxes(viewdir)
%
%
%
switch viewdir
	case 1
		idxes = [2 3];
	case 2
		idxes = [1 3];
	case 3
		idxes = [2 1];
end

