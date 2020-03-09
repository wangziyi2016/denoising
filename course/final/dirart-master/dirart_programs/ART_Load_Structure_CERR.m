function [structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR(filename)
%
%	[structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR(filename)
%	[structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR(planC)
%
structs = [];
assocScanIDs = [];
scanInfos = [];

if ~exist('filename','var')
	[filename, pathname] = uigetfile({'*.mat'}, 'Select CERR plan to load structures');
	if filename == 0
		return;
	end

	filename = [pathname filename];
end

if ischar(filename)
	% Load planC from file
	setinfotext('Loading is CERR plan ...');
	load(filename);
else
	planC = filename;
end

indexS = planC{end};

structure_names = ListStructureNames(planC{indexS.structures});
if isempty(structure_names)
	setinfotext('No structures to load');
	return;
end

[sels,ok] = listdlg('ListString',structure_names,'ListSize',[300 200],'Name','Structure Selection','PromptString','Please select structure(s) to load');
drawnow;
if ok == 0 || isempty(sels)
	setinfotext('Structures loading is cancelled');
	return;
end

drawnow;
structIndexes = sels;

% Make sure structure meshes are computed
N = length(structIndexes);
assocScanIDs = getStructureAssociatedScan(structIndexes,planC);
scanInfos = cell(max(assocScanIDs),1);
uniqScanIDs = unique(assocScanIDs);
for k = 1:length(uniqScanIDs)
    [xVals, yVals, zVals] = getScanXYZVals(planC{indexS.scan}(uniqScanIDs(k)));
	dim = size(planC{indexS.scan}(uniqScanIDs(k)).scanArray);
	scanInfo.xVals = xVals*10;
	scanInfo.yVals = yVals*10;
	scanInfo.zVals = zVals*10;
	scanInfo.dim = dim;
	scanInfo.UID = planC{indexS.scan}(uniqScanIDs(k)).scanUID;
	scanInfos{uniqScanIDs(k)} = scanInfo;
end

currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir);
end

hbar = waitbar(0,'Loading structures');
try
	structs = cell(N,1);
	for k = 1:N
		structIndex = structIndexes(k);
		strname = planC{indexS.structures}(structIndex).structureName;
		waitbar((k-1)/N,hbar,sprintf('Loading structure %s',strname));
		isgood = 1;
% 		if ~isfield(planC{indexS.structures}(structIndex),'meshRep') || (isfield(planC{indexS.structures}(structIndex),'meshRep') && (isempty(planC{indexS.structures}(structIndex).meshRep) || planC{indexS.structures}(structIndex).meshRep == 0))
			fprintf('Generating meshRep for structure: %s\n',strname);
			% Check the associated scans
			assocScanID = assocScanIDs(k);
			scanInfo = scanInfos{assocScanID};
			xVals = scanInfo.xVals/10;
			yVals = scanInfo.yVals/10;
			zVals = scanInfo.zVals/10;
			structUID   = planC{indexS.structures}(structIndex).strUID;
			waitbar((k-0.8)/N,hbar,sprintf('getRasterSegments for structure %s',strname));
			[rasterSegments, planC]    = getRasterSegments(structIndex,planC);
			waitbar((k-0.6)/N,hbar,sprintf('rasterToMask for structure %s',strname));
			[mask3M, uniqueSlices] = rasterToMask(rasterSegments, assocScanID,planC);
			if isempty(uniqueSlices)
				isgood = 0;
			elseif length(uniqueSlices) > 1 && ~isempty(meshDir)
				waitbar((k-0.5)/N,hbar,sprintf('Generating meshRep for structure %s',strname));
				mask3M = permute(mask3M,[2 1 3]);
				smoothIter = 0;
				% 			smoothIter = 2;
				calllib('libMeshContour','clear',structUID)
				calllib('libMeshContour','loadVolumeAndGenerateSurface',structUID,xVals,yVals,zVals(uniqueSlices), double(mask3M),0.5, uint16(smoothIter))
				%Store mesh under planC
				planC{indexS.structures}(structIndex).meshS = calllib('libMeshContour','getSurface',structUID);
				planC{indexS.structures}(structIndex).meshRep = 1;
			else
				fprintf('\nSkip this 1 slice structure\n\n');
				planC{indexS.structures}(structIndex).meshS = [];
				planC{indexS.structures}(structIndex).meshRep = 0;
			end
% 		end
		
		if isgood == 1
			structs{k} = planC{indexS.structures}(structIndex);
		else
			structs{k} = [];
		end
	end
catch ME
	cd(currDir);
	structs = [];
	assocScanIDs = [];
	scanInfos = [];
	fprintf('Failed to load structures, error: %s.\n',ME.message);
% 	e = lasterror;
	print_stack(ME.stack);
	return;
end

close(hbar);
cd(currDir);



