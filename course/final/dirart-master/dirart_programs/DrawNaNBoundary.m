function DrawNaNBoundary(handles,idx,timg,xs,ys)
%
%	DrawNaNBoundary(handles,idx,timg,xs,ys)
%

% if isempty(timg) || Check_MenuItem(handles.gui_handles.Options_Draw_Nan_Boundaries_Menu_Item) == 0
if isempty(timg) || handles.gui_options.display_NaN_boxes(idx) == 0
	return;
end

if size(timg,3) > 1
	timg = sum(timg,3);
end

nanmask = isnan(timg);
if sum(nanmask(:)) == 0
	return;
end

hold on;
linew = 3;
[cc,hc] = contour(xs,ys,(~nanmask)>0,[0 0 0],':','LineWidth',linew,'LineColor','r');
set(hc,'hittest','off');


