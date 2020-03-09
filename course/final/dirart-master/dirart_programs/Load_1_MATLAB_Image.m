function [img,pathname] = Load_1_MATLAB_Image
%
%	 [img,pathname] = Load_1_MATLAB_Image
%

[filename, pathname] = uigetfile({'*.mat'}, 'Select a MATLAB file to load the image');	% Load a 3D image in MATLAB *.mat file
if filename == 0
	img = [];
	return;
end

img = CreateEmptyImage;
img.image = load_image_from_MATLAB_file(fullfile(pathname,filename));
if isstruct(img.image)
	img = img.image;
	return;
end

img.filename = [pathname filesep filename];
img.LoadFrom = 'MATLAB';

[dummy,voxelsize] = InputImageVoxelSizeRatio([1 1 1], 'Enter voxel size for the image in mm');
if ~isempty(dummy)
	img.original_voxelsize = voxelsize;
	img.voxelsize = voxelsize;
else
	img = [];
	return;
end

