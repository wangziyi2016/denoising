function DrawContours(handles,idx,max_projection)
%
%
%
% If the image dimensions are different
display_deformed_contour = Check_MenuItem(handles.gui_handles.Options_Display_Deformed_Structure_Contours_Menu_Item,0);
display_contour_in_own_view = Check_MenuItem(handles.gui_handles.Display_Structure_In_Own_View_Menu_Item,0);

displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
imgidx = WhichImageCoordinateToUse(displaymode);
slidervalues = handles.gui_options.slidervalues(idx,:);
[slidervalues1,slidervalues2] = ConvertSliderValues(handles,slidervalues,displaymode);

image_current_offsets = handles.reg.images_setting.image_current_offsets;
hAxes = gca;

[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);
vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
vecidx = WhichImageCoordinateToUse(displaymode);
vec = vecs(vecidx);

vec1in1 = GetImageCoordinateVectors(handles,1,viewdir,1);
vec1in2 = GetImageCoordinateVectors(handles,1,viewdir,2);
vec2in1 = GetImageCoordinateVectors(handles,2,viewdir,1);
vec2in2 = GetImageCoordinateVectors(handles,2,viewdir,2);

if vecidx == 1
	imgvecs(1) = vec1in1;
	imgvecs(2) = vec2in1;
else
	imgvecs(1) = vec1in2;
	imgvecs(2) = vec2in2;
end


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
	display_contour_1 = Check_MenuItem(handles.gui_handles.Options_Display_Structure_Contours_1_Menu_Item,0);
	display_contour_2 = Check_MenuItem(handles.gui_handles.Options_Display_Structure_Contour_2_Menu_Item,0);
end


structure_masks_1 = [];
structure_masks_2 = [];
expanded_structure_masks = [];
deformed_structure_masks = [];


if display_contour_1 == 1
	structure_masks_1 = handles.images(1).structure_mask;
	if isfield(handles.reg,'expanded_structure_masks')
		expanded_structure_masks = handles.reg.expanded_structure_masks;
	end
end

if display_contour_2 == 1
	structure_masks_2 = handles.images(2).structure_mask;
end

if display_deformed_contour == 1
	if isfield(handles.reg,'deformed_structure_masks')
		deformed_structure_masks = handles.reg.deformed_structure_masks;
	end
end

if isempty(structure_masks_1)
	display_contour_1 = 0;
end
if isempty(structure_masks_2)
	display_contour_2 = 0;
end
if isempty(deformed_structure_masks)
	display_deformed_contour = 0;
end

[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);

if display_contour_1 == 1
	if ~isempty(structure_masks_1)
		structure_masks_1 = Get_Image_Slice(structure_masks_1,viewdir,dimc,img1_offsets_c,slidervalues1+img1_offsets_c,max_projection*2);
		if viewdir ~= 3
			structure_masks_1 = structure_masks_1';
		end
	end
	if ~isempty(expanded_structure_masks)
		expanded_structure_masks = Get_Image_Slice(expanded_structure_masks,viewdir,dimc,img1_offsets_c,slidervalues1+img1_offsets_c,max_projection*2);
		if viewdir ~= 3
			expanded_structure_masks = expanded_structure_masks';
		end
	end
end
if display_contour_2 == 1
	if ~isempty(structure_masks_2)
		structure_masks_2 = Get_Image_Slice(structure_masks_2,viewdir,dimc,img2_offsets_c,slidervalues2+img2_offsets_c,max_projection*2);
		if viewdir ~= 3
			structure_masks_2 = structure_masks_2';
		end
	end
end

if display_deformed_contour == 1
	if ~isempty(deformed_structure_masks)
		deformed_structure_masks = Get_Image_Slice(deformed_structure_masks,viewdir,dimc,img1_offsets_c,image_current_offsets+slidervalues+img1_offsets_c,max_projection*2);
		if viewdir ~= 3
			deformed_structure_masks = deformed_structure_masks';
		end
	end
end
		
if display_contour_1 == 1 || display_deformed_contour == 1 || display_contour_2 == 1
	hold on;

	linecolormap = lines(64);
	if isfield(handles,'contour_line_thickness')
		linewidth = handles.gui_options.contour_line_thickness(idx);
	else
		linewidth = 2;
	end

	if display_contour_1 == 1
		if max(structure_masks_1(:)) > 0
			structure_masks_1 = double(structure_masks_1);
			% 			linetypes = {'-','-.','--'};
			NC = floor(log2(max(structure_masks_1(:))))+1;
			for k = 1:NC
				maskbit = bitget(uint32(structure_masks_1),k);
				if max(maskbit(:)) > 0
					cs = contourd(vec.xs,vec.ys,double(maskbit),[1 1]);
					plot_contourd(hAxes,cs,'LineStyle','-','Color',linecolormap(k,:),'LineWidth',linewidth);
				end
			end
		end
		if max(expanded_structure_masks(:)) > 0
			expanded_structure_masks = double(expanded_structure_masks);
			% 			linetypes = {'-','-.','--'};
			NC = floor(log2(max(expanded_structure_masks(:))))+1;
			for k = 1:NC
				maskbit = bitget(uint32(expanded_structure_masks),k);
				if max(maskbit(:)) > 0
					cs = contourd(vec.xs,vec.ys,double(maskbit),[1 1]);
					plot_contourd(hAxes,cs,'LineStyle','.','Color',linecolormap(k+1,:),'LineWidth',linewidth);
				end
			end
		end
	end

	if display_contour_2 == 1 && max(structure_masks_2(:)) > 0
		structure_masks_2 = double(structure_masks_2);
		% 			linetypes = {'-','-.','--'};
		NC = floor(log2(max(structure_masks_2(:))))+1;
		for k = 1:NC
			maskbit = bitget(uint32(structure_masks_2),k);
			if max(maskbit(:)) > 0
				cs = contourd(vec.xs,vec.ys,double(maskbit),[1 1]);
				plot_contourd(hAxes,cs,'LineStyle','-.','Color',linecolormap(k+2,:),'LineWidth',linewidth);
			end
		end
	end

	if display_deformed_contour == 1 && max(deformed_structure_masks(:)) > 0
		deformed_structure_masks = double(deformed_structure_masks);
		% 			linecolormap = lines(64);
		% 			linetypes = {'-','-.','--'};
		% 			linewidth = 2;
		NC = floor(log2(max(deformed_structure_masks(:))))+1;
		for k = 1:NC
			maskbit = bitget(uint32(deformed_structure_masks),k);
			if max(maskbit(:)) > 0
				cs = contourd(vec.xs,vec.ys,double(maskbit),[1 1]);
				% 					plot_contourd(hAxes,cs,'LineStyle','.','Color',linecolormap(k,:),'LineWidth',linewidth);
				plot_contourd(hAxes,cs,'LineStyle','--','Color',linecolormap(k,:),'LineWidth',linewidth);
				% 					plot_contourd(hAxes,cs,'LineStyle',linetypes{mod(k+NC-1,3)+1},'Color',linecolormap(k+NC,:),'LineWidth',linewidth);
			end
		end
	end
end


