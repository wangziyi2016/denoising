function ConditionalRefreshDisplay(handles,displaymodestoupdate)
%{
A supporting function used by deformable registration GUI
This function will update the panels if the display mode of the panels matching the selected modes

Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%}

global skipdisplay;
if isempty(skipdisplay)
	skipdisplay = 1;
	pause(0.1);
	skipdisplay = 0;
elseif skipdisplay == 1
	pause(1);
	skipdisplay = 0;
else
	skipdisplay = 1;
	pause(0.2);
	skipdisplay = 0;
end

for idx=1:7
	if (skipdisplay==1) 
		continue; 
	end

	if any(handles.gui_options.display_mode(idx,2) == displaymodestoupdate)
		update_display(handles,idx);
	end
end
return;

