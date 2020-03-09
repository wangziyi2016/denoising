function planC = AddNewStructureToPlanC(handles,strnums,planC)
%
%	planC = AddNewStructureToPlanC(handles,strnums,planC)
%

planCfromFile = 0;

if ~exist('planC','var')
	[planC,filename] = LoadCERRPlanC();
	if isempty(planC)
		return;
	end
	planCfromFile = 1;
	setinfotext(sprintf('planC is loaded from file: %s', filename));
end

indexS = planC{end};
numStructs = length(planC{indexS.structures});

scanno = SelectScanFromPlanC(planC,'Select an scan to associate the structures');
if scanno == 0
	return;
end

newStructs = handles.ART.structures(strnums);
[xVals,yVals,zVals] = GetScanXYZVals(planC{indexS.scan}(scanno));

N = length(newStructs);
NumStructAdd = 0;
for k = 1:N
	targetScanUID = planC{indexS.scan}(scanno).scanUID;
	imgidx = handles.ART.structure_assocImgIdxes(strnums(k));
	structScanUID = handles.images(imgidx).UID;
	
	if strcmpi(targetScanUID,structScanUID) ~= 1
		msg = sprintf('Structure "%s" is not for the selected scan in the planC, skips.',handles.ART.structure_names{strnums(k)});
		msgbox(msg,'Structure not for the scan','warn','modal');
		continue;
	end
	
	struct1 = GetElement(newStructs,k);
	struct1 = ResliceStructures(struct1,zVals);
	struct1.associatedScan = scanno;
	struct1.assocScanUID = targetScanUID;
	struct1.rasterSegments = [];
	struct1.meshS = [];
	struct1.contour = makecolumnVector(struct1.contour);
	
	planC{indexS.structures} = dissimilarInsert(planC{indexS.structures}, struct1, numStructs+k, []);
	% Create Raster Segments
	planC = getRasterSegs(planC, numStructs+k);
	% Update uniformized data.
	planC = updateStructureMatrices(planC, numStructs+1);
	NumStructAdd = NumStructAdd+1;
end

if NumStructAdd > 0 && planCfromFile == 1
	[filename2,pathname] = uiputfile('*.mat','Save planC with new structures',filename);
	if filename2 == 0
		setinfotext('New structures are not saved into planC');
		return;
	else
		save([pathname filename2],'planC');
		setinfotext(sprintf('%d structures are added to planC',N));
	end
end


