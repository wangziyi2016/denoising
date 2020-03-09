function imgidx = WhichImageCoordinateToUse(displaymode)
%
%
%
switch displaymode
	case {1,4}
		imgidx = 1;
	otherwise
		imgidx = 2;
end

