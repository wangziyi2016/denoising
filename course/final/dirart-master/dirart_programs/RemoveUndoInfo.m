
% --------------------------------------------------------------------
function handles = RemoveUndoInfo(handles)
if isfield(handles,'undo_handles')
	handles = rmfield(handles,'undo_handles');
	guidata(handles.gui_handles.figure1,handles);	
end
return;

