function hfig = update_display(handles,idx)
%
%	hfig = update_display(handles,idx)
%
% Update the display in 1 of the 7 display panel
% This is the main display function.
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

global skipdisplay;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
if isempty(skipdisplay)
	skipdisplay = 0;
end

if skipdisplay == 1 || strcmpi(get(handles.gui_handles.axes_handles(idx),'visible'),'off') == 1
	return; 
end

% curfigure = gcf;
curfigure = handles.gui_handles.figure1;
hfig = gcf;
hold off;

if isempty(handles.images(1).image) || handles.gui_options.display_enabled(idx) == 0
	hAxes = handles.gui_handles.axes_handles(idx);
	set(handles.gui_handles.figure1,'CurrentAxes',hAxes);
	display_flat_image(hAxes,0);
	set(hAxes,'xtick',[],'ytick',[]);
	return;
end

displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
if ndims(handles.images(1).image) < 3
	viewdir = 3;	% Only use transverse view for 2D images
end
xidxes = [2 1 2];
yidxes = [3 3 1];
xidx = xidxes(viewdir);
yidx = yidxes(viewdir);

if handles.gui_options.display_destination == 1
	hAxes = handles.gui_handles.axes_handles(idx);
	set(handles.gui_handles.figure1,'CurrentAxes',hAxes);
else
	hfig = figure(idx+10);
	hAxes = gca;
end

switch displaymode
	case {2,5,7,9,12}
		imgidx = 2;
	otherwise
		imgidx = 1;
end

[CLow, CHigh] = get_CLim_from_window_levels(idx);

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);
moving_image = handles.images(1).image;
fixed_image = handles.images(2).image;

image_current_offsets = handles.reg.images_setting.image_current_offsets;
yoffs = (1:dim2(1))+image_current_offsets(1);	% Image 1 voxel positions corresponding to image 2
xoffs = (1:dim2(2))+image_current_offsets(2);
zoffs = (1:dim2(3))+image_current_offsets(3);

% compute the common dimension if image 1 and 2 are different in dimension
[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);
vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
vecidx = WhichImageCoordinateToUse(displaymode);
vec = vecs(vecidx);

if handles.gui_options.display_maxprojection == 1
	[xlimits,ylimits]= get_display_geometry_limits(handles,idx,1);
else
	switch viewdir
		case 1
			xlimits = handles.gui_options.display_limits(idx,displaymode).xlimits;
			ylimits = handles.gui_options.display_limits(idx,displaymode).zlimits;
		case 2
			xlimits = handles.gui_options.display_limits(idx,displaymode).ylimits;
			ylimits = handles.gui_options.display_limits(idx,displaymode).zlimits;
		case 3
			xlimits = handles.gui_options.display_limits(idx,displaymode).xlimits;
			ylimits = handles.gui_options.display_limits(idx,displaymode).ylimits;
	end
end

i1vx0 = handles.images(1).image;
i2vx0 = handles.images(2).image;
if ~isempty(handles.images(1).image_deformed)
	i1vx0 = handles.images(1).image_deformed;
end
if ~isempty(handles.images(2).image_deformed)
	i2vx0 = handles.images(2).image_deformed;
end

if isequal(size(i1vx0),size(i2vx0)) && ~isequal(dim1,dim2)
	temp = zeros(dim1);
	temp(yoffs,xoffs,zoffs) = i1vx0;
	i1vx0 = temp;
	clear temp;
end

i1vx = i1vx0;
i2vx = i2vx0;

slidervalues = handles.gui_options.slidervalues(idx,:);
[slidervalues1,slidervalues2] = ConvertSliderValues(handles,slidervalues,displaymode);

max_projection = handles.gui_options.display_maxprojection;

moving_image = Get_Image_Slice(moving_image,viewdir,dimc,img1_offsets_c,slidervalues1+img1_offsets_c,max_projection);
fixed_image = Get_Image_Slice(fixed_image,viewdir,dimc,img2_offsets_c,slidervalues2+img2_offsets_c,max_projection);
i1vx = Get_Image_Slice(i1vx,viewdir,dimc,img1_offsets_c,slidervalues1+img1_offsets_c,max_projection);
i2vx = Get_Image_Slice(i2vx,viewdir,dimc,img2_offsets_c,slidervalues2+img2_offsets_c,max_projection);


if( imgidx == 1 )
	img = moving_image;
else
	img = fixed_image;
end

if any(displaymode == [6 7 19 20])
	if( displaymode == 6 || displaymode == 19)
		srcimg = moving_image;
		dstimg = fixed_image;
	else
		srcimg = i1vx;
		dstimg = i2vx;
	end
	
	if handles.gui_options.difference_image_range == 0
		srcimg = WindowTransformImageIntensity(srcimg,reg3dgui_global_windows_centers(idx),reg3dgui_global_windows_widths(idx));
		dstimg = WindowTransformImageIntensity(dstimg,reg3dgui_global_windows_centers(idx),reg3dgui_global_windows_widths(idx));
	end

	diffimg = srcimg - dstimg;
end

% maximg = max(img(:));

warning off;

timg = [];
%aspts = [];

for k = 1:3
	handles.gui_options.slidervales(k) = get(handles.gui_handles.sliderhandles(k),'Value');
end

if (skipdisplay == 1)	
	return; 
end

MAPLEVEL = 128;
MAP = gray(MAPLEVEL);
MAPinColor = GetColormapByName(handles.gui_options.colormap,MAPLEVEL);
if any(displaymode == [1,2,3,4,5,6,7,19,20,10])
	if handles.gui_options.display_image_in_color(idx) == 1
		MAP = MAPinColor;
	else
		MAP = gray(MAPLEVEL);
	end
end

if displaymode == 4
	img = i1vx;
elseif displaymode == 5
	img = i2vx;
end

if displaymode == 8
	checkersrc = moving_image;
	checkerdes = fixed_image;
else
	checkersrc = i1vx;
	checkerdes = i2vx;
end

checkersrc = WindowTransformImageIntensity(checkersrc,reg3dgui_global_windows_centers(idx),reg3dgui_global_windows_widths(idx));
checkerdes = WindowTransformImageIntensity(checkerdes,reg3dgui_global_windows_centers(idx),reg3dgui_global_windows_widths(idx));

if (skipdisplay == 1)	
	return; 
end

if handles.gui_options.display_enabled(idx) == 0
	displaymode = 0;
end

% Here we actually display the image
timg = [];
switch( displaymode )
	case 0	% Disable
		himg = display_flat_image(hAxes,0);
	case {1,2,4,5}
		if viewdir ~= 3
			img = img';
		end
		himg = imagesc(vec.xs,vec.ys,img,[CLow, CHigh]);
		colormap(hAxes,MAP);
		timg = img;
	case 3	% Composite image
% 		timg(:,:,1) = moving_image*0;
		timg(:,:,1) = fixed_image;
		timg(:,:,2) = fixed_image;
		timg(:,:,3) = i1vx;
		if viewdir ~= 3
			timg = permute(timg,[2 1 3]);
		end
		timg = min(timg,CHigh); timg = timg - CLow; timg = max(timg,0);
		timg = timg / (CHigh-CLow);
		himg = image(vec.xs,vec.ys,timg);
	case {6,7,19,20}	% Difference image
		if viewdir ~= 3
			diffimg = diffimg';
		end
		if handles.gui_options.difference_image_range == 0
			maxCL = min(abs(CHigh), max(abs(diffimg(:))));
		else
			maxCL = handles.gui_options.difference_image_range;
		end
		
		if maxCL == 0
			maxCL = max(maxCL,1e-6);
		end
		
		if displaymode <= 7	% in gray
			himg = imagesc(vec.xs,vec.ys,diffimg,[-maxCL maxCL]);
			colormap(hAxes,MAP);
		else	% in color
			diffimg = diffimg / 2 / maxCL + 0.5;
			diffimg = min(diffimg,1); diffimg = max(diffimg,0);
% 			diffimg = ColorRemap(diffimg,jet);
			diffimg = ColorRemap(diffimg,MAPinColor);
			himg = image(vec.xs,vec.ys,diffimg);
		end
		timg = diffimg;
	case {8,9}	% Checkerboard display
		colorweight = handles.gui_options.display_checkerboard_in_color(idx)*0.1;
		checkerboard_size = GetCheckerboardGridSize(handles,idx);
		tempimg = make_checkerboard(checkersrc,checkerdes,[checkerboard_size(xidx) checkerboard_size(yidx)],colorweight);
		if viewdir ~= 3
			tempimg = permute(tempimg,[2 1 3]);
		end
		tempimg = max(tempimg,0);
		timg = tempimg/max(tempimg(:));
		himg = image(vec.xs,vec.ys,timg);
	otherwise
		warning('Display mode has not been implemented');
end

if handles.gui_options.keep_aspect_ratio(idx) == 1
	daspect([1 1 1]);
else
	axis fill;
end

dim_idxes = GetDimensionIdxes(viewdir);
if handles.images(vecidx).voxel_spacing_dir(dim_idxes(1)) < 0
	set(hAxes,'XDir','reverse');
end
if handles.images(vecidx).voxel_spacing_dir(dim_idxes(2)) < 0
	set(hAxes,'YDir','normal');
else
	set(hAxes,'YDir','reverse');
end
% 	set(himg,'alphadata',handles.gui_options.alphas(idx));
set(hAxes,'xlim',xlimits,'ylim',ylimits);

if exist('himg','var') && ishandle(himg)
	set(himg,'hittest','off');
end


if any(displaymode == [6 7 10 14:17])
	colormap(hAxes,MAP);
	if handles.gui_options.display_colorbar(idx) == 1
		if 	handles.gui_options.display_destination == 1
			cbar_axes = colorbar('east');
		else
			cbar_axes = colorbar;
		end
		if any( displaymode == 6:7 )
			set(cbar_axes,'YColor',[1 1 1]);
		end
	end
end

DrawLandmarks(handles,idx);	% Draw land marks
DisplayDose(handles,idx);
DrawDVF(handles,idx);
DrawCheckerboardGridLines(handles,idx);
DrawBoundaryBoxes(handles,idx);
DrawARTStructures(handles,idx,max_projection);
Draw_ROI_Box(handles,idx);	% Draw 3D ROI box
DrawNaNBoundary(handles,idx,timg,vec.xs,vec.ys);

if handles.gui_options.display_destination == 1
	DrawImageInfo(handles,idx,hAxes);
end

v = sscanf (version, '%d.%d.%d') ;
v = 10.^(0:-1:-(length(v)-1)) * v ;
if Check_MenuItem(handles.gui_handles.Options_Show_Pixel_Information_Menu_Item,0) == 1 && v <= 7.3
	impixelinfo;
end
	
if handles.gui_options.display_destination == 1
	set(hAxes,'xtick',[],'ytick',[]);
% 	figure(curfigure);
else
	axis off;
end
drawnow;

return;

function [CLow, CHigh] = get_CLim_from_window_levels(idx)
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths
if isempty(reg3dgui_global_windows_centers)
	Use_Default_Window_Level(guidata(gcf));
end
CLow = reg3dgui_global_windows_centers(idx) - reg3dgui_global_windows_widths(idx)/2;
CHigh = reg3dgui_global_windows_centers(idx) + reg3dgui_global_windows_widths(idx)/2;
return;

