function ART_Add_Structure_2_PlanC(handles)
%
%	ART_Add_Structure_2_PlanC(handles)
%

[strnums,ok] = listdlg('ListString',handles.ART.structure_names,'ListSize',[200 300],'Name','Structure Selection','PromptString','Please select structure(s) to export');
if ok == 0 || isempty(strnums)
	setinfotext('Structures 2 planC is cancelled');
	return;
end

AddNewStructureToPlanC(handles,strnums);


