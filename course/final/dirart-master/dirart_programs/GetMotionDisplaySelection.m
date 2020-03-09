function sel = GetMotionDisplaySelection(handles)
%{
This is a supporting function used by the deformable registration GUI.

%}
if ~exist('handles','var')
	handles = guidata(gcf);
end

menuitems = get(handles.gui_handles.Motion_Field_Selection_Menu,'child');

for k = 1:length(menuitems);
	if strcmp(get(menuitems(k),'Checked'),'on')
		break;
	end
end

sel = length(menuitems)-k+1;
