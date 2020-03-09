function DrawCheckerboardGridLines(handles,idx)
%
%
% Checkerboard image grid lines
%	
displaymode = handles.gui_options.display_mode(idx,2);
if handles.gui_options.display_checkerboard_gridlines(idx) == 1 && displaymode >= 8 && displaymode <= 9
% if Check_MenuItem(handles.gui_handles.OptionsDisplayGridLinesMenuItem,0) == 1 && displaymode >= 8 && displaymode <= 9
	viewdir = handles.gui_options.display_mode(idx,1);
	imgidx = WhichImageCoordinateToUse(displaymode);

	dimc = ComputeCombinedImageInfo(handles);
	idxes = GetDimensionIdxes(viewdir);
	dim = dimc(idxes);
	checkerboard_size = GetCheckerboardGridSize(handles,idx);

	hold on;

	maxy = dim(2);
	maxx = dim(1);
	spacey = checkerboard_size(idxes(2));
	spacex = checkerboard_size(idxes(1));
	
	vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
	vecs = vecs(2);
	
	colorv = [0.4 0.4 0.4];
	LW = 3;

	NX = ceil(maxx/spacex);
	if (NX-1)*spacex <= maxx
		NX = NX + 1;
	end
	
	for nx = 2:NX-1
		x1 = (nx-1)*spacex;
		x = (vecs.xs(x1)+vecs.xs(x1-1))/2;
		L = line([x x],[vecs.ys(1) vecs.ys(end)]);
		set(L,'color',colorv,'LineStyle',':','LineWidth',LW,'hittest','off');
	end

	NY = ceil(maxy/spacey);
	if (NY-1)*spacey < maxy
		NY = NY + 1;
	end

	for ny = 2:NY-1
		y1 = (ny-1)*spacey;
		y = (vecs.ys(y1)+vecs.ys(y1-1))/2;
% 		y = (ny-1)*spacey - 0.5;
		L=line([vecs.xs(1) vecs.xs(end)],[y y]);
		set(L,'color',colorv,'LineStyle',':','hittest','off','LineWidth',LW);
	end
end
