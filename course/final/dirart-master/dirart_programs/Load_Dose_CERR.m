function dose = Load_Dose_CERR(wholename)
%
%	dose = Load_Dose_CERR(wholename)
%	dose = Load_Dose_CERR(planC)
%
dose = [];

if ~exist('wholename','var')
	[filename, pathname] = uigetfile({'*.mat'}, 'Select CERR plan to load dose');
	if filename == 0
		return;
	end

	wholename = [pathname filename];
end

dose = CreateEmptyImage;
dose = rmfield_from_struct(dose,'structure_mask');
dose.filename = wholename;

if ischar(wholename)
	disp('Loading dose from CERR file ...');
	load(wholename);
else
	planC = wholename;
end

indexS = planC{end};
N = length(planC{indexS.dose});
scanstrs = cell(N,1);
for k = 1:N
	scanstrs{k} = planC{indexS.dose}(k).fractionGroupID;
	if isempty(scanstrs{k})
		scanstrs{k} = sprintf('Dose %d',k);
	end
end

if N > 1
	[doseno,ok]=listdlg('ListString',scanstrs,'SelectionMode','single','Name','Load dose from CERR plan','PromptString','There are multiple doses in the CERR plan, please select one dose');
	if ok == 0
		return;
	end
else
	doseno = 1;
end

doseCERR = planC{indexS.dose}(doseno);

dose.image = doseCERR.doseArray;
dose.image = single(squeeze(dose.image));
dose.type = 'Dose';

dim = size(dose.image);

% dose.image = dose.image * doseCERR.doseScale * 100;

zValues = doseCERR.zValues;
SliceThickness = abs(zValues(2)-zValues(1))*10;

dose.voxelsize = abs([doseCERR.verticalGridInterval*10 doseCERR.horizontalGridInterval*10 SliceThickness]);
dose.original_voxelsize = dose.voxelsize; 
% dose.origin = [doseCERR.coord2OFFirstPoint doseCERR.coord1OFFirstPoint zValues(1)];
dose.origin = [doseCERR.coord2OFFirstPoint doseCERR.coord1OFFirstPoint zValues(1)]*10;

% dose.voxel_spacing_dir = sign([doseCERR.horizontalGridInterval doseCERR.verticalGridInterval zValues(2)-zValues(1)]);
dose.voxel_spacing_dir = sign([doseCERR.verticalGridInterval doseCERR.horizontalGridInterval zValues(2)-zValues(1)]);

dose.ys = makeRowVector(dose.origin(1) + ((1:dim(1))-1)*dose.voxelsize(1)*dose.voxel_spacing_dir(1));
dose.xs = makeRowVector(dose.origin(2) + ((1:dim(2))-1)*dose.voxelsize(2)*dose.voxel_spacing_dir(2));
dose.zs = makeRowVector(zValues*10);

if isfield(doseCERR,'DICOMHeaders')
	dose.DICOM_Info = doseCERR.DICOMHeaders;
else
	dose.DICOM_Info = [];
end
dose.Description = scanstrs{doseno};
dose.UID = doseCERR.doseUID;
dose.assocScanUID = doseCERR.assocScanUID;
dose.LoadFrom = 'CERR';
doseCERR.doseArray = [];
dose.original_CERR_Dose_Struct = doseCERR;
dose = rmfield_from_struct(dose,'original_CERR_Scan_Struct');

if ~isfield(doseCERR,'doseUnits') || isempty(doseCERR.doseUnits)
    doseCERR.doseUnits = 'GRAY';
end

switch upper(doseCERR.doseUnits)
% 	case {'CGYS','CGY','CGRAYS'}
% 		dose.image = dose.image;
	case {'GY','GYS','GRAYS','GRAY'}
		dose.image = dose.image * 100;
end

dose.Units = 'cGys';



