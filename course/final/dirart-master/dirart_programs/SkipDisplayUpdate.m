function SkipDisplayUpdate()
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


