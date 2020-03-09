function DrawImageInfo(handles,idx,hAxes)
%
%
%
ylims = get(hAxes,'YLim');
xlims = get(hAxes,'XLim');
ydir = 1;
xdir = 1;
if strcmpi(get(hAxes,'YDir'),'reverse')
	ylims = fliplr(ylims);
	ydir = -1;
end
if strcmpi(get(hAxes,'XDir'),'reverse')
	xlims = fliplr(xlims);
	xdir = -1;
end

% posa = get(hAxes,'Position');

displaymode = handles.gui_options.display_mode(idx,2);

display_mode_strings{1} = 'Moving';
display_mode_strings{2} = 'Fixed';
display_mode_strings{3} = 'Combined';
display_mode_strings{4} = 'Deformed Moving';
display_mode_strings{5} = 'Deformed Fixed';
display_mode_strings{6} = 'Diff (Before)';
display_mode_strings{7} = 'Diff (After)';
display_mode_strings{8} = 'Before';
display_mode_strings{9} = 'After';
display_mode_strings{10} = 'Jacobian';
display_mode_strings{11} = 'Before registration';
display_mode_strings{12} = 'After registration';
display_mode_strings{13} = '3D view';
display_mode_strings{14} = 'DVF-X';
display_mode_strings{15} = 'DVF-Y';
display_mode_strings{16} = 'DVF-Z';
display_mode_strings{17} = 'Abs(DVF)';
display_mode_strings{18} = 'Motion Field Color Coded';
display_mode_strings{19} = 'Diff (Before)';
display_mode_strings{20} = 'Diff (After)';

viewdir_strings{1} = 'Cor';
viewdir_strings{2} = 'Sag';
viewdir_strings{3} = 'Tra';

% if strcmpi(get(gca,'Units'),'normalized')
% 	posa = normalized2pixel(posa,handles.gui_handles.figure1);
% end

dim = GetImageDisplayDimensionAndOffsets(handles,displaymode);
viewdir = handles.gui_options.display_mode(idx,1);
slidervalue = handles.gui_options.slidervalues(idx,viewdir);

[rx,ry] = ComputeAxesLimitToPositionRatio(hAxes);
% switch displaymode
% 	case {1,4}
% 		vec = GetImageCoordinateVectors(handles,1);
% 	case {2,5,10,14,15,16,17}
% 		vec = GetImageCoordinateVectors(handles,2);
% 	otherwise
% 		vecs = GetCombinedImageCoordinateVectors(handles);
% 		vec = vecs(WhichImageCoordinateToUse(displaymode));
% end

% switch viewdir
% 	case 1
% 		v = vec.ys;
% 	case 2
% 		v = vec.xs;
% 	case 3
% 		v = vec.zs;
% end

% if slidervalue < 1 || slidervalue > length(v)
% 	coord = (v(1) + (slidervalue-1)*(v(2)-v(1)));
% else
% 	coord = (v(slidervalue));
% end
% 
coord = GetCurrentSliceCoordinate(handles,idx);

htext = text(xlims(1)+4/rx*xdir,ylims(1)+20/ry*ydir,...
	sprintf('%s - %s\n%.1f mm (%d / %d)',display_mode_strings{displaymode},viewdir_strings{viewdir},coord,slidervalue,dim(viewdir)));
if idx == handles.gui_options.current_axes_idx
	fontsize = 12;
	set(htext,'Color','red','FontSize',fontsize+2,'color',[1 0.5 0.5],'FontWeight','bold','hittest','off');
else
	fontsize = 10;
	set(htext,'Color','red','FontSize',fontsize,'hittest','off');
end
set(htext,'tag',['label' num2str(idx)]);




