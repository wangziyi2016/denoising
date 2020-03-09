function handles = AddNewStructures(handles,structs,assocScanIDs,scanInfos)
%
%	handles = AddNewStructures(handles,structs,assocScanIDs,scanInfos)
%	handles = AddNewStructures(handles,structs,assocScanIDs)
%
N = length(structs);
N0 = length(handles.ART.structures);
structure_structInfos = ProcessCERRStructures(structs);
if isempty(structure_structInfos)
	return;
end

structure_names = ListStructureNames(structs);
colors = lines(N0+N);
handles.ART.structure_display(N0+(1:N)) = ones(1,N);
handles.ART.structure_colors(N0+(1:N),:) = colors(N0+(1:N),:);

if exist('scanInfos','var')
	handles.ART.structure_assocScanIDs(N0+(1:N)) = assocScanIDs+length(handles.ART.structure_scanInfos);
else
	handles.ART.structure_assocScanIDs(N0+(1:N)) = assocScanIDs;
end

for k = 1:N
	if isempty(structs{k}) || isempty(structure_structInfos(k))
		continue;
	end
	
	handles.ART.structures{end+1} = structs{k};
	handles.ART.structure_names{end+1} = structure_names{k};
	handles.ART.structure_structInfos{end+1} = structure_structInfos(k);
end

if exist('scanInfos','var')
	for k = 1:length(scanInfos)
% 		if ~isempty(scanInfos{k})
			handles.ART.structure_scanInfos{end+1} = scanInfos{k};
% 		end
	end
end

handles = ProcessStructureImgAssociation(handles);

