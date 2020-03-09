function [idx,haxes] = FindCurrentAxes(handles)
%
%
%
found = 0;
for idx = 1:length(handles.gui_handles.axes_handles)
	haxes = handles.gui_handles.axes_handles(idx);
	if get(handles.gui_handles.figure1,'currentaxes') == haxes
		found = 1;
		break;
	end
end

if found == 0
	idx = -1;
	haxes = [];
end


