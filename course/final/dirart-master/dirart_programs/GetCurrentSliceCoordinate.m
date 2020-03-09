function coord = GetCurrentSliceCoordinate(handles,idx)
%
%	coord = GetCurrentSliceCoordinate(handles,idx)
%
viewdir = handles.gui_options.display_mode(idx,1);
displaymode = handles.gui_options.display_mode(idx,2);
slidervalue = handles.gui_options.slidervalues(idx,viewdir);

switch displaymode
	case {1,4}
		vec = GetImageCoordinateVectors(handles,1);
	case {2,5,10,14,15,16,17}
		vec = GetImageCoordinateVectors(handles,2);
	otherwise
		vecs = GetCombinedImageCoordinateVectors(handles);
		vec = vecs(WhichImageCoordinateToUse(displaymode));
end

switch viewdir
	case 1
		v = vec.ys;
	case 2
		v = vec.xs;
	case 3
		v = vec.zs;
end

if slidervalue < 1 
    if length(v) == 1
        % 2D images
        coord = v(1);
    else
        % extrapolate
    	coord = (v(1) + (slidervalue-1)*(v(2)-v(1)));
    end
elseif slidervalue > length(v)
	coord = (v(1) + (slidervalue-1)*(v(2)-v(1)));
else
	coord = (v(slidervalue));
end

