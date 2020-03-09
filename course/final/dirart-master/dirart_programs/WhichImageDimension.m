function imgidx = WhichImageDimension(displaymode)
%
%
%
switch displaymode
	case {1,4}
		imgidx = 1;
	case {2,5,10,14,15,16,17}
		imgidx = 2;
	otherwise
		imgidx = 3;
end

