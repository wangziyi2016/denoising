function Pad_Both_Images(handles)
%
%	Pad_Both_Images(handles)
%
%	Automatic path both images
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);

if isequal(dim1,dim2) && isequal(handles.reg.images_setting.image_offsets,[0 0 0])
	disp('No need of padding');
	return;
end

padval = Input_Image_Padding_Value;
if isempty(padval)
	disp('Padding is cancelled');
	return;
end

% compute the common dimension if image 1 and 2 are different in dimension
[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);

img1 = ones(dimc)*padval;
img2 = img1;
ys1 = (1:dim1(1))+img1_offsets_c(1);
xs1 = (1:dim1(2))+img1_offsets_c(2);
zs1 = (1:dim1(3))+img1_offsets_c(3);
ys2 = (1:dim2(1))+img2_offsets_c(1);
xs2 = (1:dim2(2))+img2_offsets_c(2);
zs2 = (1:dim2(3))+img2_offsets_c(3);
img1(ys1,xs1,zs1) = handles.images(1).image;
img2(ys2,xs2,zs2) = handles.images(2).image;

handles.reg.images_setting.cropped_image_offsets_in_original(1,:) = handles.reg.images_setting.cropped_image_offsets_in_original(1,:) - img1_offsets_c;
handles.images(1).image = img1;
handles.images(1).origin = handles.images(1).origin - handles.images(1).voxelsize .* handles.images(1).voxel_spacing_dir .* img1_offsets_c;
handles.reg.images_setting.cropped_image_offsets_in_original(2,:) = handles.reg.images_setting.cropped_image_offsets_in_original(2,:) - img2_offsets_c;
handles.images(2).image = img2;
handles.images(2).origin = handles.images(2).origin - handles.images(2).voxelsize .* handles.images(2).voxel_spacing_dir .* img2_offsets_c;

handles = Logging(handles,'Both images are padded to match sizes each other');
handles.reg.images_setting.image_offsets = [0 0 0];
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;

handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);


