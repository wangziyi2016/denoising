function SaveDoseDICOMRT(handles)
%
%	SaveDoseDICOMRT(handles)
%
dosestrs = GenerateDoseDescriptionList(handles.ART.dose);
doseidx = max(WhichDoseToDisplay(handles,1),1);
[sel,ok] = listdlg('ListString',dosestrs,'SelectionMode','single','ListSize',[300 300],'PromptString','Select a dose to save','InitialValue',doseidx);
if ok == 0
	return;
end

[filename, pathname] = uiputfile({'*.dcm'}, 'Enter a DICOM filename to save the selected dose');
if filename == 0
	return;
end

filename = [pathname filename];
dose = handles.ART.dose{sel};

% if strcmpi(dose.LoadFrom,'CERR') == 1 && isfield(dose,'DICOM_Info') && ~isempty(dose.DICOM_Info) 
if isfield(dose,'DICOM_Info') && ~isempty(dose.DICOM_Info) 
	% Convert RTOG coordinates to DICOM coordinates
	[xVals yVals zVals] = GetDoseXYZVals(dose.original_CERR_Dose_Struct);
	[xVals2 yVals2 zVals2] = GetDICOMXYZVals(dose.original_CERR_Dose_Struct);

	if strcmpi(dose.LoadFrom,'DICOM via CERR') == 1
		zVals2 = fliplr(MakeRowVector(zVals2));
	end

	dose.xs=interp1(xVals*10,xVals2,dose.xs,'linear','extrap');
	dose.ys=interp1(yVals*10,yVals2,dose.ys,'linear','extrap');
	dose.zs=interp1(zVals*10,zVals2,dose.zs,'linear','extrap');
	dose.origin(1) = interp1(yVals*10,yVals2,dose.origin(1),'linear','extrap');
	dose.origin(2) = interp1(xVals*10,xVals2,dose.origin(2),'linear','extrap');
	dose.origin(3) = interp1(zVals*10,zVals2,dose.origin(3),'linear','extrap');
	dose.voxel_spacing_dir(3) = sign(dose.zs(2)-dose.zs(1));
	dose.voxel_spacing_dir(2) = sign(dose.xs(2)-dose.xs(1));
	dose.voxel_spacing_dir(1) = sign(dose.ys(2)-dose.ys(1));
end

if dose.voxel_spacing_dir(3) < 0
	dose.image = flipdim(dose.image,3);
	dose.zs = fliplr(dose.zs);
	dose.origin(3) = dose.zs(1);
	dose.voxel_spacing_dir(3) = 1;
end

if dose.voxel_spacing_dir(1) < 0
	dose.image = flipdim(dose.image,1);
	dose.ys = fliplr(dose.ys);
	dose.origin(1) = dose.ys(1);
	dose.voxel_spacing_dir(1) = 1;
end

if dose.voxel_spacing_dir(2) < 0
	dose.image = flipdim(dose.image,2);
	dose.xs = fliplr(dose.xs);
	dose.origin(2) = dose.xs(1);
	dose.voxel_spacing_dir(2) = 1;
end


DICOM_Info = dose.DICOM_Info;
DICOM_Info.PixelSpacing = [dose.voxelsize(2);dose.voxelsize(1)];
DICOM_Info.SliceThickness = dose.voxelsize(3);
DICOM_Info.ImagePositionPatient = dose.origin([2 1 3]);
DICOM_Info.ImageOrientationPatient(1) = dose.voxel_spacing_dir(2);
DICOM_Info.ImageOrientationPatient(5) = dose.voxel_spacing_dir(1);
DICOM_Info.GridFrameOffsetVector = (dose.zs - dose.zs(1))';
DICOM_Info.DoseGridScaling = ceil(max(dose.image(:)))/100/32767;
dosearray = int16(dose.image/100/DICOM_Info.DoseGridScaling);	% in Gy
DICOM_Info.NumberOfFrames = size(dosearray,3);
DICOM_Info.Rows = size(dosearray,1);
DICOM_Info.Columns = size(dosearray,2);
DICOM_Info.DoseUnits = 'GRAYS';
DICOM_Info.DoseSummationType = 'MATLAB Saved Dose';
DICOM_Info = rename_struct_field(DICOM_Info,'ReferringPhysiciansName','ReferringPhysicianName');
DICOM_Info = rename_struct_field(DICOM_Info,'PatientsName','PatientName');
DICOM_Info = rename_struct_field(DICOM_Info,'PhysiciansofRecord','PhysicianOfRecord');
DICOM_Info = rename_struct_field(DICOM_Info,'PatientsBirthDate','PatientBirthDate');
DICOM_Info = rename_struct_field(DICOM_Info,'PatientsSex','PatientSex');

DICOM_Info.PatientName = rmfield_from_struct(DICOM_Info.PatientName,{'NamePrefix','NameSuffix'});
if ischar(DICOM_Info.FrameIncrementPointer)
	FrameIncrementPointer = round([hex2dec(DICOM_Info.FrameIncrementPointer(1:4)) hex2dec(DICOM_Info.FrameIncrementPointer(5:8))]);
	DICOM_Info.FrameIncrementPointer = FrameIncrementPointer;
end
dicomwrite(dosearray,filename,DICOM_Info,'CreateMode','copy');


