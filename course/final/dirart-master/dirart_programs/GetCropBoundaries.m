function [x1,y1,x2,y2] = GetCropBoundaries(H,confirm)
rect = round(getrect(H));
if rect(3)+rect(4) == 0
	x1 = [];
	x2 = [];
	y1 = [];
	y2 = [];
	return;
end

x1 = rect(1); y1 = rect(2);
x2 = rect(1)+rect(3); y2 = y1+rect(4);
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
x1 = max(x1,xlim(1)); y1 = max(y1,ylim(1));
x2 = min(x2,xlim(2)); y2 = min(y2,ylim(2));

if confirm == 1
	x = [x1 x2 x2 x1 x1];
	y = [y1 y1 y2 y2 y1];
	hl=line(x,y);
	set(hl,'Color','r');
	ButtonName=questdlg('Is the region acceptable?', ...
		'Mark Image Region','No','Yes','Yes');
	delete hl;
	drawnow;

	if strcmp(ButtonName,'Yes') == 0
		setinfotext('Image region is not acceptable.')
		x1 = [];
		x2 = [];
		y1 = [];
		y2 = [];
	end
end

