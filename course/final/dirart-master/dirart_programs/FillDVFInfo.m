function handles = FillDVFInfo(handles,whichDVF)
%
%	handles = FillDVFInfo(handles,whichDVF)
%
%	whichDVF =	1,	for DVF
%				2,	for IDVF
%				3,	for both

% By default, the DVF will have the same image information as the fixed
% image

if whichDVF == 1 || whichDVF == 3
	if isempty(handles.reg.dvf.x)
		handles.reg.dvf.info = [];
	else
		handles.reg.dvf.info = rmfield_from_struct(handles.images(2),{'image','original_voxelsize','structure_mask','image_deformed','filename','structure_name','DICOM_Info','original_CERR_Scan_Struct','LoadFrom'});
		handles.reg.dvf.info.UID = createUID('DVF');
		handles.reg.dvf.info.Fixed_Image_UID = handles.images(2).UID;
		handles.reg.dvf.info.Moving_Image_UID = handles.images(1).UID;
		handles.reg.dvf.info.class = 'single';
		handles.reg.dvf.info.type = 'DVF';
		handles.reg.dvf.info.GenerateBy = 'Reg3dGUI';
	end
end

if whichDVF == 2 || whichDVF == 3
	if isempty(handles.reg.idvf.x)
		handles.reg.idvf.info = [];
	else
		handles.reg.idvf.info = rmfield_from_struct(handles.images(1),{'image','original_voxelsize','structure_mask','image_deformed','filename','structure_name','DICOM_Info','original_CERR_Scan_Struct','LoadFrom'});
		handles.reg.idvf.info.UID = createUID('DVF');
		handles.reg.idvf.info.Fixed_Image_UID = handles.images(1).UID;
		handles.reg.idvf.info.Moving_Image_UID = handles.images(2).UID;
		handles.reg.idvf.info.class = 'single';
		handles.reg.idvf.info.type = 'DVF';
		handles.reg.idvf.info.GenerateBy = 'Reg3dGUI';
	end
end


