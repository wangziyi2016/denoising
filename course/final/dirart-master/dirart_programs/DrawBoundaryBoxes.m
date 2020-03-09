function DrawBoundaryBoxes(handles,idx)
%
%	DrawBoundaryBoxes(handles,idx)
%
if handles.gui_options.display_boundary_boxes(idx)==1
	displaymode = handles.gui_options.display_mode(idx,2);
	viewdir = handles.gui_options.display_mode(idx,1);

	vecidx = WhichImageCoordinateToUse(displaymode);

	imgvecs(1) = GetImageCoordinateVectors(handles,1,viewdir,vecidx);
	imgvecs(2) = GetImageCoordinateVectors(handles,2,viewdir,vecidx);

	xlimits_img1 = GetLimitsFromVector(imgvecs(1).xs);
	ylimits_img1 = GetLimitsFromVector(imgvecs(1).ys);
	xlimits_img2 = GetLimitsFromVector(imgvecs(2).xs);
	ylimits_img2 = GetLimitsFromVector(imgvecs(2).ys);

	% 	bf = 0.5;	% Boundary offset
	bf = 1;
	linew = 5;
	px = [xlimits_img2(1)-bf xlimits_img2(2)+bf xlimits_img2(2)+bf xlimits_img2(1)-bf xlimits_img2(1)-bf];
	py = [ylimits_img2(1)-bf ylimits_img2(1)-bf ylimits_img2(2)+bf ylimits_img2(2)+bf ylimits_img2(1)-bf];
	hl = line(px,py);
	set(hl,'LineWidth',linew,'LineStyle',':','color',[0.5 0 0]);
	set(hl,'hittest','off');
	px = [xlimits_img1(1)-bf xlimits_img1(2)+bf xlimits_img1(2)+bf xlimits_img1(1)-bf xlimits_img1(1)-bf];
	py = [ylimits_img1(1)-bf ylimits_img1(1)-bf ylimits_img1(2)+bf ylimits_img1(2)+bf ylimits_img1(1)-bf];
	hl = line(px,py);
	set(hl,'LineWidth',linew,'LineStyle',':','color',[0 0 0.5]);
	set(hl,'hittest','off');
end
