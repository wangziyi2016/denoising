function offs = GetOffsetInCoordinates(handles)
% offs = GetOffsetInCoordinates(handles)
% Positions of the image 2 origin in the image 1 coordinates
%

offs = handles.reg.images_setting.image_current_offsets .* handles.images(1).voxelsize .* handles.images(1).voxel_spacing_dir;


