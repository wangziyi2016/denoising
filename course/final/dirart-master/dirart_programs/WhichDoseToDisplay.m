function doseidx = WhichDoseToDisplay(handles,idx)
%
%	doseidx = WhichDoseToDisplay(handles)
%	doseidx = WhichDoseToDisplay(handles,idx)
%
if ~exist('idx','var')
	idx = 1:handles.gui_options.num_panels;
end

% doseidx = 0;
% dosemenus = get(handles.gui_handles.Dose_Menu,'child');
% if ~isempty(dosemenus)
% 	N = length(dosemenus);
% 	for k = 1:N
% 		if Check_MenuItem(dosemenus(k),0) == 1
% 			doseidx = N-k+1;
% 			break;
% 		end
% 	end
% end


doseidx = handles.gui_options.DoseDisplayOptions.dose_to_display(idx);
