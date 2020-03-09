function DrawDVF(handles,idx)
%
%	DrawDVF(handles,idx)
%
motion_field_selection = handles.gui_options.DVF_displays(idx,1);
if  motion_field_selection == 0
	return;
end

motion_display_mode = handles.gui_options.DVF_displays(idx,2);
if motion_display_mode == 1
	return;
end

displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
imgidx_in_display = WhichImageCoordinateToUse(displaymode);

dvf.x = [];
dvf.y = [];
dvf.z = [];

dvf_base_imgidx = 2;
dvfinfo = handles.reg.dvf.info;
switch motion_field_selection
	case 1
		dvf.x = handles.reg.dvf.x;
		dvf.y = handles.reg.dvf.y;
		dvf.z = handles.reg.dvf.z;
	case 2
		dvf.x = handles.reg.idvf.x;
		dvf.y = handles.reg.idvf.y;
		dvf.z = handles.reg.idvf.z;
		dvfinfo = handles.reg.idvf.info;
		dvf_base_imgidx = 1;
	case 3
		if isfield(handles.reg,'mvx_resolution')
			dvf.x = handles.reg.mvx_resolution;
			dvf.y = handles.reg.mvy_resolution;
			dvf.z = handles.reg.mvz_resolution;
		end
	case 4
		if isfield(handles.reg,'mvx_pass')
			dvf.x = handles.reg.mvx_pass;
			dvf.y = handles.reg.mvy_pass;
			dvf.z = handles.reg.mvz_pass;
		end
	case 5
		if isfield(handles.reg,'mvx_iteration')
			dvf.x = handles.reg.mvx_iteration;
			dvf.y = handles.reg.mvy_iteration;
			dvf.z = handles.reg.mvz_iteration;
		end
end

if isempty(dvf.x)
	return;
end


motionvectorcolor = 'yellow';
display_in_color = strcmp(get(handles.gui_handles.OptionsDisplayColorMenuItem,'Checked'),'on');
if display_in_color == 1
	motionvectorcolor = 'white';
end


dvf.y = dvf.y * dvfinfo.voxelsize(1);
dvf.x = dvf.x * dvfinfo.voxelsize(2);
dvf.z = dvf.z * dvfinfo.voxelsize(3);

dim = mysize(dvf.x);

gridsize0 = handles.gui_options.motion_grid_size(idx,:);
gridsize = max(1,ceil(gridsize0 ./ dvfinfo.voxelsize));
s = round(gridsize/2);

% vvs = GetImageCoordinateVectors(handles,dvf_base_imgidx);
[ys,xs,zs] = get_image_XYZ_vectors(dvfinfo,dvf.x);

y0 = s(1):gridsize(1):dim(1);
x0 = s(2):gridsize(2):dim(2);
z0 = s(3):gridsize(3):dim(3);

y02 = ys(y0);
x02 = xs(x0);
z02 = zs(z0);

if imgidx_in_display ~= dvf_base_imgidx
	[x02,y02,z02] = TranslateCoordinates(handles,dvf_base_imgidx,x02,y02,z02);
end

coord = GetCurrentSliceCoordinate(handles,idx);
coord = Translate1CoordinateValue(handles,imgidx_in_display,dvf_base_imgidx,viewdir,coord);

[ys,xs,zs] = get_image_XYZ_vectors(dvfinfo,dvf.x);
switch motion_display_mode
	case 2
		switch viewdir
			case 1
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord)';
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord)';
				mv2=mv2(x0,z0)';
				mv1=mv1(x0,z0)';
				[vv1,vv2] = meshgrid(x02,z02);
			case 2
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord)';
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord)';
				mv2=mv2(y0,z0)';
				mv1=mv1(y0,z0)';
				[vv1,vv2] = meshgrid(y02,z02);
			case 3
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord);
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord);
				mv2=mv2(y0,x0);
				mv1=mv1(y0,x0);
				[vv1,vv2] = meshgrid(x02,y02);
		end
	case 3
		x02 = xs;
		y02 = ys;
		z02 = zs;
		if imgidx_in_display ~= dvf_base_imgidx
			[x02,y02,z02] = TranslateCoordinates(handles,dvf_base_imgidx,x02,y02,z02);
		end

		switch viewdir
			case 1
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord);
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord);
				[vv1,vv2] = meshgrid(x02,z02);
				gridsizex = gridsize(2);
				gridsizey = gridsize(3);
			case 2
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord);
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord);
				[vv1,vv2] = meshgrid(y02,z02);
				gridsizex = gridsize(1);
				gridsizey = gridsize(3);
			case 3
				mv1 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord);
				mv2 = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord);
				[vv1,vv2] = meshgrid(x02,y02);
				gridsizex = gridsize(2);
				gridsizey = gridsize(1);
		end
	otherwise
end

hold on;
linew = handles.gui_options.motion_vector_line_width(idx);

switch motion_display_mode
	case 2
		% display the DVF vector
		if motion_field_selection ~= 2
			% backward DVF
			idxes = ~isnan(mv1) & ~isnan(mv2);
			vv1=vv1(idxes);
			vv2=vv2(idxes);
			mv1=mv1(idxes);
			mv2=mv2(idxes);

			mh = quiver(vv1-mv1,vv2-mv2,mv1,mv2,0,'Color',motionvectorcolor,'LineWidth',linew);
			set(mh,'hittest','off');
		else
			% forward DVF
			idxes = ~isnan(mv1) & ~isnan(mv2);
			vv1=vv1(idxes);
			vv2=vv2(idxes);
			mv1=mv1(idxes);
			mv2=mv2(idxes);

			mh = quiver(vv1,vv2,mv1,mv2,0,'Color',motionvectorcolor,'LineWidth',linew);
			set(mh,'hittest','off');
		end
	case 3
		% display the deformation grid
		if motion_field_selection ~= 2
			% backward DVF
			for M = round(gridsizex/2):gridsizex:size(mv1,1)
				X = vv1(M,:)-mv1(M,:);
				Y = vv2(M,:)-mv2(M,:);
				L=line(X,Y);
				set(L,'Color',motionvectorcolor,'LineWidth',linew);
				set(L,'hittest','off');
			end

			for M = round(gridsizey/2):gridsizey:size(mv1,2)
				X = vv1(:,M)-mv1(:,M);
				Y = vv2(:,M)-mv2(:,M);
				L=line(X,Y);
				set(L,'Color',motionvectorcolor,'LineWidth',linew);
				set(L,'hittest','off');
			end
		else
			% forward DVF
			for M = round(gridsizex/2):gridsizex:size(mv1,1)
				X = vv1(M,:)+mv1(M,:);
				Y = vv2(M,:)+mv2(M,:);
				L=line(X,Y);
				set(L,'Color',motionvectorcolor,'LineWidth',linew);
				set(L,'hittest','off');
			end

			for M = round(gridsizey/2):gridsizey:size(mv1,2)
				X = vv1(:,M)+mv1(:,M);
				Y = vv2(:,M)+mv2(:,M);
				L=line(X,Y);
				set(L,'Color',motionvectorcolor,'LineWidth',linew);
				set(L,'hittest','off');
			end
		end
	case {4,5,6,7,8,9}
		% display colorwash
		offs = GetCoordinateOffsets(handles,dvf_base_imgidx,imgidx_in_display);
		idxes = GetDimensionIdxes(viewdir);
		if motion_display_mode == 4
			[mv,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord);
		elseif motion_display_mode == 5
			[mv,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord);
		elseif motion_display_mode == 6
			[mv,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord);
		elseif motion_display_mode == 7	% absolute motion vector
			mvx = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.x,viewdir,coord);
			mvy = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.y,viewdir,coord);
			[mvz,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,dvf.z,viewdir,coord);
			if isempty(mvx) || isempty(mvy) || isempty(mvz)
				return;
			end
			mv = sqrt(mvz.^2+mvx.^2+mvy.^2);
		elseif motion_display_mode == 8
			if isfield(handles.reg,'jacobian')
				[mv,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,handles.reg.jacobian,viewdir,coord);
			else
				return;
			end
		elseif motion_display_mode == 9
			if isfield(handles.reg,'inverse_consistency_errors')
				[mv,xs,ys] = Get_Image_Slice_By_Coordinate(ys,xs,zs,handles.reg.inverse_consistency_errors,viewdir,coord);
			else
				return;
			end
		end
		
		if isempty(mv)
			return;
		end
		
		xs = xs + offs(idxes(1));
		ys = ys + offs(idxes(2));
		
		if viewdir ~= 3
			mv = mv';
		end

		nanmask = ~isnan(mv);
		nanmask = repmat(nanmask,[1 1 3]);

		MAPinColor = GetColormapByName(handles.gui_options.DVF_colormap,128);
		mv = NormalizeData(mv);
		mvc = ColorRemap(mv,MAPinColor);
		mvc = mvc.*nanmask;
		h=image(xs,ys,mvc);
		set(h,'AlphaData',handles.gui_options.DVF_colorwash_alpha(idx),'hittest','off');
end



		
