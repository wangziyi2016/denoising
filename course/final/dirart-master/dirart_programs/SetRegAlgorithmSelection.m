function handles = SetRegAlgorithmSelection(handles)
%
% handles = SetRegAlgorithmSelection(handles)
%

% Turn off all menus
reg_algorithm_menus = get(handles.gui_handles.Registration_Algorithms_Menu,'child');
N = length(reg_algorithm_menus);
for k = 1:N
	children = get(reg_algorithm_menus(k),'child');
	if isempty(children)
		set(reg_algorithm_menus(k),'checked','off');
	else
		set(children,'checked','off');
	end
end

map = RegMethod_Menu_Map;
max_method_num = max([map.method]);

% Turn on the menu for the selected method
if handles.reg.registration_method >= 1 && handles.reg.registration_method <= max_method_num
    idx = find([map.method] == handles.reg.registration_method,1,'first');
    if isempty(idx)
        warning('DIRART:INTERNAL_PROBLEMS','Mismatching in the DIRART program');
    else
        set(handles.gui_handles.(map(idx).menu_name),'checked','on');
    end
end

set(get(handles.gui_handles.Registration_Framework_Menu,'child'),'checked','off');
switch lower(handles.reg.registration_framework)
	case 'consistency'
		set(handles.gui_handles.Inverse_Consistency_Registration_Menu_Item,'checked','on');
	case 'region_smoothing'
		set(handles.gui_handles.Regional_Smoothing_Menu_Item,'checked','on');
	case 'asymmetric'
		set(handles.gui_handles.Asymmetric_Registration_Framework_Menu_Item,'checked','on');
		handles.reg.registration_framework = 'asymmetric';
end

