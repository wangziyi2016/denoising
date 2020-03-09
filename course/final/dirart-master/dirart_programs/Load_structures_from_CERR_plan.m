% --- Executes on button press in loadimage1button.
function [masks,names] = Load_structures_from_CERR_plan(planC)
masks = [];
names = [];

indexS = planC{end};
if ~isempty(planC{indexS.structures})
	namelist = ListStructureNames(planC{indexS.structures});
% 	N = length(planC{indexS.structures});
% 	for k = 1:N
% 		namelist{k} = planC{indexS.structures}(k).structureName;
% 	end
	[structs_to_load,ok] = listdlg('ListString',namelist,'Name','Load structures');

	if ok == 1 && ~isempty(structs_to_load)
		for k = 1:length(structs_to_load)
			mask = uint32(CERRGetStructureRasterSegment(planC,structs_to_load(k)));
			if k == 1
				masks = mask;
			else
				masks = bitor(masks,bitshift(mask,k-1));
			end
			names{k} = planC{indexS.structures}(structs_to_load(k)).structureName;
		end
	end
else
	disp('No structure information in the CERR plan');
	masks = [];
	names = [];
% 	ButtonName=questdlg(sprintf('There is no structures in the CERR plan %s, to load structures from DICOM RT file?',filename), ...
% 		'Structure Loading','No','Yes','Yes');
% 
% 	if strcmp(ButtonName,'No') == 0
% 		masks = [];
% 		names = [];
% 		return;
% 	else
% 		dirname = uigetfile('','Select the original DICOM images folder');
% 		disp('Loading MVCT image from DICOM ...');
% 		[ct,ctinfo,zs] = load_3d_image_dicom([dirname filesep '*.dcm']);
% 
% 		[filename1, pathname1] = uigetfile({'*.dcm;*.roi'}, 'Select DICOM RT file');
% 		[mvmasks,struct_names] = get_structure_mask_from_dicom([pathname1 filename1],size(mvct),ctinfo,zs);
% 		disp('Loading MVCT contours ...');
% 
% 		
% 		ctinfo.PixelSpacing = [planC{3}.uniformScanInfo.grid1Units planC{3}.uniformScanInfo.grid1Units]*10;
% 		ctinfo.ImagePositionPatient = planC{3}.
% 	end
end
