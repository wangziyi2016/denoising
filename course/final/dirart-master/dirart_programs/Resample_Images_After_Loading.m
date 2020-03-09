function handles = Resample_Images_After_Loading(handles)
%
%
%
if isequal(round(handles.images(1).voxelsize*100),round(handles.images(2).voxelsize*100))
	uiwait(msgbox(['Voxel sizes of two images are the same. ' ...
		'Images could be resampled to a difference voxel sizes. '...
		sprintf('\n\nCurrent image voxel size = [%s]\n',num2str(handles.images(1).voxelsize,'%g  ')) ...
		'Please enter resampling voxel sizes in the next step'],'Optional'));
else
	% Two images are in different voxelsizes, have to be resampled
	uiwait(msgbox(['Voxel sizes of two images are not the same. ' ...
		'Images need to be resampled to the same voxel sizes. '...
		sprintf('\n\nImage 1 voxel size = [%s]\n',num2str(handles.images(1).voxelsize,'%g  ')) ...
		sprintf('Image 2 voxel size = [%s]\n\n',num2str(handles.images(2).voxelsize,'%g  ')) ...
		'Please enter resampling voxel sizes in the next step'],'Warning'));
end

target_voxelsize = max(handles.images(1).voxelsize,handles.images(2).voxelsize);
[dummy,voxelsize] = InputImageVoxelSizeRatio(target_voxelsize, 'Enter resampling voxel size in mm');
handles.images(1).original_voxelsize = handles.images(1).voxelsize;
handles.images(2).original_voxelsize = handles.images(2).voxelsize;
if ~isempty(dummy)
	handles.images(1).voxelsize = voxelsize;
else
	voxelsize = handles.images(1).voxelsize;
end
handles.images(2).voxelsize = voxelsize;
	
if ~isequal(round(voxelsize*10000),round(handles.images(1).original_voxelsize*10000))
	% Resampling image #1
	handles = Logging(handles,'Resampling images 1 to voxel size = [%s]', num2str(handles.images(1).voxelsize,'%g  '));
	setinfotext('Resampling image #1 ...'); drawnow;
	disp('Resampling image #1 ...');
	tic
	handles.images(1).image = resample_3D_image(handles.images(1).image,handles.images(1).original_voxelsize,'spacing',handles.images(1).voxelsize(1:2),'thickness',handles.images(1).voxelsize(3));
	toc
	handles = Logging(handles,'\tImage size after resampling = [%s]',num2str(size(handles.images(1).image),'%d '));
end
	
if ~isequal(round(voxelsize*10000),round(handles.images(2).original_voxelsize*10000))
	% Resampling image #2
	handles = Logging(handles,'Resampling images 2 to voxel size = [%s]', num2str(handles.images(2).voxelsize,'%g  '));
	setinfotext('Resampling image #2 ...'); drawnow;
	disp('Resampling image #2 ...');
	tic
	handles.images(2).image = resample_3D_image(handles.images(2).image,handles.images(2).original_voxelsize,'spacing',handles.images(2).voxelsize(1:2),'thickness',handles.images(2).voxelsize(3));
	toc
	handles = Logging(handles,'\tImage size after resampling = [%s]',num2str(size(handles.images(2).image),'%d '));
end

handles.reg.images_setting.image_offsets = round(handles.reg.images_setting.image_offsets.*handles.images(1).original_voxelsize./handles.images(1).voxelsize);
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
handles = RecoverImageAlignmentPoints(handles);

