function DrawPOI(handles,idx,strnum,maxprojection)
%
%	DrawPOI(handles,idx,strnum,maxprojection)
%
displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
linecolor = handles.ART.structure_colors(strnum,:);
sliceCoord = GetCurrentSliceCoordinate(handles,idx);

c = ComputeStructureCenterPos(handles,strnum);
if WhichImageCoordinateToUse(displaymode) ~= handles.ART.structure_assocImgIdxes(strnum)
	[c(2) c(1) c(3)] = TranslateCoordinates(handles,handles.ART.structure_assocImgIdxes(strnum),c(2),c(1),c(3));
end
	
r = 5; % within 10 mm

d = abs(c(viewdir)-sliceCoord);
if d > r && maxprojection == 0
	return;
end

d = r*(r-d);
if maxprojection == 1
	d = r;
end

dimidxes = GetDimensionIdxes(viewdir);
cx = c(dimidxes(1));
cy = c(dimidxes(2));

d = max(1,round(d));
plot(cx,cy,'+','markersize',d*2,'color',linecolor,'linewidth',3);





