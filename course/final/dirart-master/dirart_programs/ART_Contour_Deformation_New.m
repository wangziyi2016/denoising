function ART_Contour_Deformation_New(handles)
%
%	ART_Contour_Deformation_New(handles)
%
[sels,ok] = listdlg('ListString',PrefixStructureNames(handles),'ListSize',[200 300],'Name','Structure Selection','PromptString','Please select structure(s) to deform');
if ok == 0 || isempty(sels)
	setinfotext('Structures deformation is cancelled');
	return;
end

setinfotext('Save Undo information');
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

drawnow;

newStructs = cell(length(sels),1);
assocScanIDs = zeros(1,length(sels));
for k = 1:length(sels)
	strnum = sels(k);
	if handles.ART.structure_assocImgIdxes(strnum) == 1 && isempty(handles.reg.idvf.x)
		newStructs{k} = Deform_1_Structure_By_Mask(handles, strnum);
	elseif handles.ART.structure_assocImgIdxes(strnum) == 2 && isempty(handles.reg.dvf.x)
		newStructs{k} = Deform_1_Structure_By_Mask(handles, strnum);
	else
		newStructs{k} = deform_1_contour_new(handles, strnum);
	end
	assocScanIDs(k) = handles.ART.structure_assocScanIDs(strnum);
end

setinfotext('Saving the new structures');
handles = AddNewStructures(handles,newStructs,assocScanIDs);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

