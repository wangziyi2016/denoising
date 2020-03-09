function value = Check_MenuItem(hObject,FlipItOver)
% This is a supporting function used by the registration GUI
% this function check the menu item checked or not-checked, and return the
% value, and flip the status of the menu item.
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%
%	value = Check_MenuItem(hObject,FlipItOver)
%
if ~exist('FlipItOver','var')
	FlipItOver = 0;
end

checked = get(hObject,'Checked');
switch checked
	case 'on'
		if FlipItOver == 0
			value = 1;
		else
			set(hObject,'Checked','off');
			value = 0;
		end
	case 'off'
		if FlipItOver == 0
			value = 0;
		else
			set(hObject,'Checked','on');
			value = 1;
		end
end

return;
