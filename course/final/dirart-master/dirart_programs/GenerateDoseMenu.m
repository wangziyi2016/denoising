function GenerateDoseMenu(handles)
submenus = get(handles.gui_handles.Dose_Menu,'child');
if ~isempty(submenus)
	delete(submenus);
end

N = length(handles.ART.dose);
for k = 1:N
	if isfield(handles.ART.dose{k},'Description') && ~isempty(handles.ART.dose{k}.Description)
		des = sprintf('%d - %s',k,handles.ART.dose{k}.Description);
	else
		des = sprintf('%d',k);
	end
	uimenu(handles.gui_handles.Dose_Menu,'label',des,'callback',sprintf('DoseMenuCallback(gcbo,guidata(gcbo),%d)',k));
end

