function DrawARTStructures(varargin)
%
%	DrawARTStructures(handles,idx)
%	DrawARTStructures(hAxes,handles,idx)
%	DrawARTStructures(...,maxprojection)
% 

maxprojection = 0;
if nargin == 2
	hAxes = gca;
	handles = varargin{1};
	idx = varargin{2};
elseif nargin == 3
	if ishandle(varargin{1})
		hAxes = varargin{1};
		handles = varargin{2};
		idx = varargin{3};
	else
		hAxes = gca;
		handles = varargin{1};
		idx = varargin{2};
		maxprojection = varargin{3};
	end
else
	hAxes = varargin{1};
	handles = varargin{2};
	idx = varargin{3};
	maxprojection = varargin{4};
end

if isempty(handles.ART.structures)
	% No structures to display
	return;
end

displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);

% draw_contour_lines = Check_MenuItem(handles.gui_handles.Display_Contour_Lines_Menu_Item,0);
draw_contour_lines = handles.gui_options.Structure_Draw_Contour_Lines(idx);
% fill_color = Check_MenuItem(handles.gui_handles.Fill_Structure_Color_Menu_Item,0);
fill_color = handles.gui_options.Structure_Fill_Color(idx);

if draw_contour_lines+fill_color == 0
	% hide all contour lines
	return;
end

N = length(handles.ART.structures);

display_contour_in_own_view = handles.gui_options.display_contour_in_own_view(idx);
if display_contour_in_own_view == 1
	switch displaymode
		case {1,3,4}
			display_contour_1 = 1;
			display_contour_2 = 0;
		case {2,3,5}
			display_contour_1 = 0;
			display_contour_2 = 1;
		otherwise
			display_contour_1 = 1;
			display_contour_2 = 1;
	end
else
	display_contour_1 = handles.gui_options.display_contour_1_in_all_views(idx);
	display_contour_2 = handles.gui_options.display_contour_2_in_all_views(idx);
end


vecidx = WhichImageCoordinateToUse(displaymode);
coord_in_display = vecidx;

currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir);
end
hold on;
for strnum = 1:N
	if handles.ART.structure_display(strnum) == 0
		continue;
	end
	
	offs= [0 0 0];
	
	if display_contour_in_own_view == 0
		% whether or not to display this contour
		if display_contour_1 == 0 && handles.ART.structure_assocImgIdxes(strnum) == 1
			continue;
		end
		if display_contour_2 == 0 && handles.ART.structure_assocImgIdxes(strnum) == 2
			continue;
		end
	end
	
	if coord_in_display ~= handles.ART.structure_assocImgIdxes(strnum)
		if display_contour_in_own_view == 1
			continue;
		end
		
		c = handles.reg.images_setting.images_alignment_points;
		if handles.ART.structure_assocImgIdxes(strnum) == 1
			offs = c(2,:)-c(1,:);
		else
			offs = c(1,:)-c(2,:);
		end
	end
	coord = GetCurrentSliceCoordinate(handles,idx)-offs(viewdir);
	structInfo = GetElement(handles.ART.structure_structInfos,strnum);
	

	struct = handles.ART.structures{strnum};
	structinfo = handles.ART.structure_structInfos{strnum};
	linecolor = handles.ART.structure_colors(strnum,:);
	
% 	if struct.meshRep == 0
	if structinfo.zmin == structinfo.zmax
		% POI
		DrawPOI(handles,idx,strnum,maxprojection);
	elseif maxprojection == 0
		segments = [];
		if viewdir == 3
			[sliceNum,coord_slice] = FindNearestSlice(structInfo.zvalues, coord);
			if isnan(sliceNum)
				continue;
			end

			s = [1 2 2 1];
			if abs(coord_slice-coord) <0.01 || isempty(meshDir)
				segments = struct.contour(sliceNum).segments;
			else
				% Transfer view
				contourS    = calllib('libMeshContour','getContours',struct.strUID,single([0 0 coord/10]),single([0 0 1]),single([1 0 0]),single([0 1 0]));
				if ~isempty(contourS) && ~isempty(length(contourS.segments))
					segments = contourS.segments;
				end
			end
		elseif viewdir == 1
			% Coronal view
			if coord > structInfo.ymax || coord < structInfo.ymin || isempty(meshDir)
				% out off bound
				continue;
			end
			contourS    = calllib('libMeshContour','getContours',struct.strUID,single([0 coord/10 0]),single([0 1 0]),single([1 0 0]),single([0 0 1]));
			if ~isempty(contourS) && ~isempty(length(contourS.segments))
				segments = contourS.segments;
				s = [1 2 3 3];
			end
		else
			% Saggital view
			if coord > structInfo.xmax || coord < structInfo.xmin || isempty(meshDir)
				% out off bound
				continue;
			end
			contourS    = calllib('libMeshContour','getContours',struct.strUID,single([coord/10 0 0]),single([1 0 0]),single([0 1 0]),single([0 0 1]));
			if ~isempty(contourS) && ~isempty(length(contourS.segments))
				segments = contourS.segments;
				s = [2 1 3 3];
			end
		end
		for k = 1:length(segments)
			points = segments(k).points*10;
			if fill_color == 1
				h=fill(points(:,s(1))+offs(s(2)),points(:,s(3))+offs(s(4)),linecolor);
				set(h,'hittest','off','FaceAlpha',handles.gui_options.Structure_Color_Fill_Alpha(idx),'LineWidth',handles.gui_options.contour_line_thickness(idx),'EdgeColor',linecolor);
				if draw_contour_lines == 0
					set(h,'EdgeColor','none','LineWidth',0.5);
				end
			else
				h=plot(hAxes,points(:,s(1))+offs(s(2)),points(:,s(3))+offs(s(4)),'color',linecolor,'LineWidth',handles.gui_options.contour_line_thickness(idx));
				set(h,'hittest','off');
			end
		end
	else
		% maxprojection
		[mask2d,ys,xs]=ProjectStructure(handles,strnum,viewdir);
		dim_idxes = GetDimensionIdxes(viewdir);
		ys = ys + offs(dim_idxes(2));
		xs = xs + offs(dim_idxes(1));
		[cc,hc]=contour(hAxes,xs,ys,mask2d,[1 1],'color',linecolor,'LineWidth',handles.gui_options.contour_line_thickness(idx));
		set(hc,'hittest','off');
	end
end
cd(currDir);
