function Apply_Structure_Masks_2_Callback(handles)
%
%
%
if isempty(handles.images(2).structure_mask)
	return;
end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

windowsize = 5;
CTbone = 1100;

offs = handles.reg.images_setting.image_offsets;
d = mysize(handles.images(2).image);
ys = (1:d(1))+offs(1);
xs = (1:d(2))+offs(2);
zs = (1:d(3))+offs(3);

mask2 = handles.images(2).structure_mask > 0;
mask1 = handles.images(1).structure_mask > 0;
mask1 = mask1(ys,xs,zs);
mask = mask1 | mask2;

handles.reg.dvf.y(mask==0) = 0;
handles.reg.dvf.x(mask==0) = 0;
handles.reg.dvf.z(mask==0) = 0;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

