function [img,pathname] = Load_1_Image_DICOM_Folder
%
%	 [img,pathname] = Load_1_Image_DICOM_Folder
%
[img3d,info,positionMatrix,orientation,pathname] = load_3d_image_dicom('*.dcm','?');

if isempty(img3d)
	return;
end

img = CreateEmptyImage;
img.image = img3d;

img.filename = pathname;
img.LoadFrom = 'DICOM Folder';

voxelsize = [info.PixelSpacing' info.SliceThickness];

% Recheck the voxel sizes for MR images
pos1 = positionMatrix * [1;1;1;1];
pos2 = positionMatrix * [1;1;2;1];
dist = sqrt(sum((pos1-pos2).^2));

if size(img3d,3) > 1
	voxelsize(3) = dist;
end

img.original_voxelsize = voxelsize;
img.voxelsize = voxelsize;
