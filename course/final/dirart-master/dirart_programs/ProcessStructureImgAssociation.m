function handles = ProcessStructureImgAssociation(handles)
%
% handles = ProcessStructureImgAssociation(handles)
%
N = length(handles.ART.structures);
N0 = length(handles.ART.structure_assocImgIdxes);

if N ~= N0
	for k = (N0+1):N
		assocScanIdx = handles.ART.structure_assocScanIDs(k);
		scanInfo = handles.ART.structure_scanInfos{assocScanIdx};
		scanUID = scanInfo.UID;
		if N0 > 0 || k > 1
			found = 0;
			for j = 1:(k-1)
				assocScanID = handles.ART.structure_assocScanIDs(j);
				if strcmpi(handles.ART.structure_scanInfos{assocScanID}.UID,scanUID) == 1
					found = 1;
					break;
				end
			end
			
			if found == 1
				handles.ART.structure_assocImgIdxes(k) = handles.ART.structure_assocImgIdxes(j);
				continue;
			end
		end
		
		handles.ART.structure_assocImgIdxes(k) = GetAssociatedImageIdx(handles,scanUID);
	end
end



