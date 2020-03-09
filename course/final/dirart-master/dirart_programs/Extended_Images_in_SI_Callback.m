function Extended_Images_in_SI_Callback(handles)
%
%	Extended_Images_in_SI_Callback(handles)
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
% dim2 = mysize(handles.images(2).image);

img1 = handles.images(1).image;
img2 = handles.images(2).image;

nans = nan(dim1(1),dim1(2),10);
img1 = cat(3,nans,img1,nans);
img2 = cat(3,nans,img2,nans);
handles.images(1).image = img1;
handles.images(2).image = img2;
handles.images(1).origin(3) = handles.images(1).origin(3) - 10 * handles.images(1).voxelsize(3) * handles.images(1).voxel_spacing_dir(3);
handles.images(2).origin(3) = handles.images(2).origin(3) - 10 * handles.images(2).voxelsize(3) * handles.images(2).voxel_spacing_dir(3);
% handles.reg.images_setting.image_offsets(3) = 0;
% handles.reg.images_setting.image_current_offsets(3) = 0;
handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);

RefreshDisplay(handles);
setinfotext('The larger image has been cropped.');

