function Extend_Image_2_SI_Callback(handles)
%
%
%

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);
off3 = handles.reg.images_setting.image_current_offsets(3);

img2 = zeros([dim2(1) dim2(2) dim1(3)],class(handles.images(1).image));
img2(:,:,(1:dim2(3))+off3) = handles.images(2).image;

prompt={'Val (boundary, 0, nan)'};
name=sprintf('Please enter the padding value');
numlines=1;
defaultanswer={'boundary'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if isempty(answer)
	return;
end

for k = 1:off3
	switch answer{1}
		case 'boundary'
			img2(:,:,k) = handles.images(2).image(:,:,1);
		case '0'
			img2(:,:,k) = 0;
		case 'nan'
			img2(:,:,k) = nan;
	end
end

for k = (dim2(3) + off3) : dim1(3)
	switch answer{1}
		case 'boundary'
			img2(:,:,k) = handles.images(2).image(:,:,end);
		case '0'
			img2(:,:,k) = 0;
		case 'nan'
			img2(:,:,k) = nan;
	end
end

handles.images(2).image = img2;

handles = Logging(handles,'Image #2 SI is padded.\n\tBefore padding, z offsets = %d, image 2 dim3 = %d.',off3, dim2(3));

handles.images(2).origin(3) = handles.images(2).origin(3) - handles.reg.images_setting.image_current_offsets(3) * handles.images(2).voxelsize(3) * handles.images(2).voxel_spacing_dir(3);
handles.reg.images_setting.cropped_image_offsets_in_original(2,3) = handles.reg.images_setting.cropped_image_offsets_in_original(2,3) - handles.reg.images_setting.image_current_offsets(3);
handles.reg.images_setting.image_current_offsets(3) = 0;
handles.reg.images_setting.image_offsets(3) = 0;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

