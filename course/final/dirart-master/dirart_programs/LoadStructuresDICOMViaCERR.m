function structS=LoadStructuresDICOMViaCERR(filename)
%
% structures=LoadStructuresDICOMViaCERR(filename)
% structures=LoadStructuresDICOMViaCERR
%

% structS = [];
structS = initializeCERR('structures');
if ~exist('filename','var')
	[filename, pathname] = uigetfile({'*.dcm'}, 'Select a DICOM ROI file');
	if filename == 0
		return;
	end
	filename = [pathname filename];
end

names   = fields(structS);
dataS = [];
a.info=[];
a.file=filename;
strobj  = scanfile_mldcm(filename);
el = strobj.get(hex2dec('30060039'));
nStructures = el.countItems;            
for j = 1:nStructures
	fprintf('.');
	for i = 1:length(names)
		dataS.(names{i}) = populate_planC_structures_field(names{i}, a, j, strobj);
	end
	structS(j)=dataS;
end
fprintf('\n');
