function checkerboard_size = GetCheckerboardGridSize(handles,idx)
%
%	checkerboard_size = GetCheckerboardGridSize(handles,idx)
%
checkerboard_size = handles.gui_options.checkerboard_size(idx,:);
if ndims(checkerboard_size) == 1
	checkerboard_size = [30 30 checkerboard_size];
end

checkerboard_size = round(checkerboard_size ./ handles.images(2).voxelsize);
checkerboard_size = max(checkerboard_size,3);

