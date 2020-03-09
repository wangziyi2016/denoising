function Draw_ROI_Box(handles,idx)
%
% Draw the 3D ROI box
%
if handles.gui_options.draw_3D_ROI == 0 || isempty(handles.gui_options.ROI3D)
	% Nothing to draw
	return;
end

linecolor = [1 1 0];
linewidth = 2;

viewdir = handles.gui_options.display_mode(idx,1);
idxes = GetDimensionIdxes(viewdir);
x = handles.gui_options.ROI3D(idxes(1),:);
y = handles.gui_options.ROI3D(idxes(2),:);

xs = [x(1) x(2) x(2) x(1) x(1)];
ys = [y(1) y(1) y(2) y(2) y(1)];

hold on;
line(xs,ys,'linewidth',linewidth,'color',linecolor);

