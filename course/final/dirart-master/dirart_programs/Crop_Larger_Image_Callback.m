% --------------------------------------------------------------------
function Crop_Larger_Image_Callback(handles)
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);

if isequal(dim1,dim2)
	return;
end

prompt={'y','x','z'};
name='To crop the larger image, please enter boundary size (in pixels)';
numlines=1;
defaultanswer={'0 0','0 0','0 0'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	disp('Cropping is cancelled');
	return;
else
	ysizes = str2num(answer{1});
	ysizes = max(ysizes,0);
	if length(ysizes) == 1
		ysizes = [ysizes ysizes];
	end
	
	xsizes = str2num(answer{2});
	xsizes = max(xsizes,0);
	if length(xsizes) == 1
		xsizes = [xsizes xsizes];
	end
	
	zsizes = str2num(answer{3});
	zsizes = max(zsizes,0);
	if length(zsizes) == 1
		zsizes = [zsizes zsizes];
	end
end

y1 = 1 + handles.reg.images_setting.image_offsets(1) - ysizes(1); y1 = max(y1,1);
y2 = dim2(1) + handles.reg.images_setting.image_offsets(1) + ysizes(2); y2 = min(y2,dim1(1));
x1 = 1 + handles.reg.images_setting.image_offsets(2) - xsizes(1); x1 = max(x1,1);
x2 = dim2(2) + handles.reg.images_setting.image_offsets(2) + xsizes(2); x2 = min(x2,dim1(2));
z1 = 1 + handles.reg.images_setting.image_offsets(3) - zsizes(1); z1 = max(z1,1);
z2 = dim2(3) + handles.reg.images_setting.image_offsets(3) + zsizes(2);  z2 = min(z2,dim1(3));

handles.images(1).image = handles.images(1).image(y1:y2,x1:x2,z1:z2);
handles.reg.images_setting.cropped_image_offsets_in_original(1,:) = handles.reg.images_setting.cropped_image_offsets_in_original(1,:) + [y1 x1 z1] - [1 1 1];
handles.images(1).origin = handles.images(1).origin + handles.images(1).voxelsize .* handles.images(1).voxel_spacing_dir .* [y1-1 x1-1 z1-1];


handles = Logging(handles,'Image #1 is cropped using [%d - %d, %d - %d], %d - %d\n\tImage size after cropping = [%s]',...
	y1,y2,x1,x2,z1,z2, num2str(size(handles.images(1).image),'%d '));

handles.reg.images_setting.image_offsets = [handles.reg.images_setting.image_offsets(1)+1-y1 handles.reg.images_setting.image_offsets(2)+1-x1 handles.reg.images_setting.image_offsets(3)+1-z1];
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
handles = reconfigure_sliders(handles);

guidata(handles.gui_handles.figure1,handles);

RefreshDisplay(handles);
setinfotext('The larger image has been cropped.');

return;
