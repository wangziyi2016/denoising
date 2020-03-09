function [control,shift]=CheckKeyModifiers(handles)
%
%
%
modifier = get(handles.gui_handles.figure1, 'CurrentModifier');
control = 0;
shift = 0;
modifiers = length(modifier);
if modifiers
	for k = 1:modifiers
		switch modifier{k}
			case 'control'
				control = 1;
			case 'shift'
				shift = 1;
		end
	end
end

