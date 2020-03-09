function [img,pathname1,planC] = Load1CERRImage(handles,use_DICOM_coordinate,planC)
%
%	[img,pathname1,planC] = Load1CERRImage(handles,use_DICOM_coordinate,planC)
%

img = [];
if ~exist('use_DICOM_coordinate','var')
	use_DICOM_coordinate = 0;
end

if ~exist('planC','var') || isempty(planC)
	[filename1, pathname1] = uigetfile({'*.mat'}, 'Select CERR plan to image');	% Load a 3D image in MATLAB *.mat file
	if filename1 == 0
		setinfotext('Loading image is cancelled');
		return;
	end

	filename1 = [pathname1,filename1];
	load(filename1);
    fprintf('Loading planC from %s\n',filename1);
	setinfotext('Image is loaded'); drawnow;
	if exist('handles','var') && ~isempty(handles)
		Logging(handles,'Image is loaded from %s', filename1);
	end
else
	pathname1 = [];
end

scanno = SelectScanFromPlanC(planC);
if scanno == 0
	return;
end

indexS = planC{end};
img = CreateEmptyImage;
img.image = planC{indexS.scan}(scanno).scanArray;
img.original_CERR_Scan_Struct = rmfield(planC{indexS.scan}(scanno),'scanArray');
info = planC{indexS.scan}(scanno).uniformScanInfo;

img.original_voxelsize = [info.grid1Units info.grid2Units info.sliceThickness]*10;
img.voxelsize = [info.grid1Units info.grid2Units info.sliceThickness]*10;
if use_DICOM_coordinate == 0
	img.LoadFrom = 'CERR';
	[xs, ys, zs] = getScanXYZVals(planC{indexS.scan}(scanno));
	img.origin = [ys(1) xs(1) zs(1)]*10;
	img.voxel_spacing_dir = sign([ys(2)-ys(1) xs(2)-xs(1) zs(2)-zs(1)]);
else
	img.LoadFrom = 'DICOM via CERR';
	info1 = planC{indexS.scan}(scanno).scanInfo(1).DICOMHeaders;
	info2 = planC{indexS.scan}(scanno).scanInfo(end).DICOMHeaders;
	img.origin = info1.ImagePositionPatient([2 1 3]);
	img.voxel_spacing_dir(2) = info1.ImageOrientationPatient(1);	% x
	img.voxel_spacing_dir(1) = info1.ImageOrientationPatient(5);	% y
	img.voxel_spacing_dir(3) = sign(info2.ImagePositionPatient(3) - info1.ImagePositionPatient(3));	% z
end
img.type = planC{indexS.scan}(scanno).uniformScanInfo.imageType;
if isfield(planC{indexS.scan}(scanno).uniformScanInfo,'scannerType')
	scannertype = lower(planC{indexS.scan}(scanno).uniformScanInfo.scannerType);
	if isfield(planC{indexS.scan}(scanno).uniformScanInfo,'scannerType') && ~isempty(findstr(scannertype,'tomotherapy'))
		dim = size(img.image);
		if dim(1) == 512 && dim(2) == 512
			img.type = 'MVCT SCAN';
		end
	end
else
	img.type = 'Unknown SCAN';
end

% Checking and loading the structure contours
% [img.structure_mask img.structure_name] = Load_structures_from_CERR_plan(planC);

if exist('filename1','var')
	img.filename = filename1;
end

if isfield(planC{indexS.scan}(scanno).scanInfo(1),'DICOMHeaders')
	img.DICOM_Info = planC{indexS.scan}(scanno).scanInfo(1).DICOMHeaders;
else
	img.DICOM_Info = [];
end
img.UID = planC{indexS.scan}(scanno).scanUID;


