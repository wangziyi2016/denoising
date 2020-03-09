% --- Executes on button press in colorcheckbox.
function RefreshDisplay(handles,idxes)
%
% RefreshDisplay(handles,idxes)
% RefreshDisplay(handles)
%
SkipDisplayUpdate();
if ~exist('idxes','var')
	idxes = 1:handles.gui_options.num_panels;
end

for k=1:length(idxes)
	idx = idxes(k);
	global skipdisplay;
	if (skipdisplay==1) 
		return; 
	end
	update_display(handles,idx);
end
