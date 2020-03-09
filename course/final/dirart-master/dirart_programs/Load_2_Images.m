function Load_2_Images(handles,sourcetype)
%
%	Load_2_Images(handles,sourcetype)
%	
%	sourcetype: 1 - MATLAB
%				2 - CERR
%				3 - DICOM (via CERR)
%				4 - DICOM files in folders (via load_3d_image_dicom)
%

handles = RemoveUndoInfo(handles);
% handles = rmfield(handles,'images');
save_images = handles.images;
current_dir = pwd;
pathname = pwd;
for k = 1:2
	setinfotext(sprintf('Loading image #%d',k));
	switch sourcetype
		case 1
			[img,pathname] = Load_1_MATLAB_Image;
		case 2
			[img,pathname,planC] = Load1CERRImage(handles,0);
		case 3
			options.scan = 1;
			[planC,pathname] = DICOMJ_Import(options);
			if isempty(planC)
				img = [];
			else
				img = Load1CERRImage(handles,1,planC);
				img.filename = pathname;
			end
		case 4
			[img,pathname] = Load_1_Image_DICOM_Folder;
	end
	
	if isempty(img)
		setinfotext(sprintf('Loading image #%d is cancelled',k));
		cd(current_dir);
% 		return;
	else
		cd(pathname);
		handles = Logging(handles,'Image #%d is loaded from %s',k,img.filename);
		handles = Logging(handles,'Image #%d voxel size = [%s]',k,num2str(img.original_voxelsize,'%g  '));
		setinfotext(sprintf('Image #%d is loaded',k)); drawnow;
		handles.images(k) = img;
		
		if sourcetype == 2
			[structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR(planC);
			clear planC;
			if ~isempty(structs)
				handles = AddNewStructures(handles,structs,assocScanIDs,scanInfos);
			end
		end
	end
end
cd(current_dir);

if isequal(save_images,handles.images) || isempty(handles.images(1).image) || isempty(handles.images(2).image)
	return;
end

After_Loading_Two_Images(handles);
