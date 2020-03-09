function [dim,offs] = GetImageDisplayDimensionAndOffsets(handles,displaymode)
%
% Output offs is referring to image 2
%
if ~exist('displaymode','var')
	displaymode = handles.gui_options.display_mode(handles.gui_options.current_axes_idx,2);
end

dim = [0 0 0];
offs = [0 0 0];
if isempty(handles.images(1).image) || displaymode == 0
	return;
end

imgidx = WhichImageDimension(displaymode);
switch imgidx
	case 1
		dim = mysize(handles.images(1).image);
		offs = -handles.reg.images_setting.image_current_offsets;
	case 2
		dim = mysize(handles.images(2).image);
	otherwise
		[dim,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);
		offs = -img2_offsets_c;
end


