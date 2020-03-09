function DisplayDose(handles,idx)
%
%	DisplayDose(handles,idx)
%
if isempty(handles.ART.dose)
	return;
end

displaymode = handles.gui_options.display_mode(idx,2);
doseidx = WhichDoseToDisplay(handles,idx);
coord_in_display = WhichImageCoordinateToUse(displaymode);
if doseidx == 0
	return;
end

dose = handles.ART.dose{doseidx};
offs = GetCoordinateOffsets(handles,dose.association,coord_in_display);

viewdir = handles.gui_options.display_mode(idx,1);
dimidxes = GetDimensionIdxes(viewdir);
coord = GetCurrentSliceCoordinate(handles,idx);
coord = Translate1CoordinateValue(handles,coord_in_display,dose.association,viewdir,coord);

maxdose = max(dose.image(:));
[img2dout,xsout,ysout] = Get_Image_Slice_By_Coordinate(dose.ys,dose.xs,dose.zs,dose.image,viewdir,coord);
if ~isempty(img2dout)
	xsout = xsout + offs(dimidxes(1));
	ysout = ysout + offs(dimidxes(2));

	hold on;
	nanmask = ones(size(img2dout));
	nanmask(img2dout<=0)=nan;
	nanmask = repmat(nanmask,[1 1 3]);

	colorwash_min = handles.gui_options.DoseDisplayOptions.colorwash_min(idx);
	colorwash_max = handles.gui_options.DoseDisplayOptions.colorwash_max(idx);
	if handles.gui_options.DoseDisplayOptions.mode(idx) == 0
		% Percentage
		isodose_lines = maxdose * handles.gui_options.DoseDisplayOptions.isodose_lines{idx}/100;
		colorwash_min = maxdose * colorwash_min/100;
		colorwash_max = maxdose * colorwash_max/100;
	else
		isodose_lines = handles.gui_options.DoseDisplayOptions.isodose_lines{idx};
	end
	isodose_lines = round(isodose_lines);
	
	alpha = 1-handles.gui_options.DoseDisplayOptions.transparency(idx);
	
% 	if Check_MenuItem(handles.gui_handles.Dose_Display_Colorwash_Menu_Item,0)==1
	if handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(idx)==1
		% Display color wash
		MAPinColor = GetColormapByName(handles.gui_options.DoseDisplayOptions.colorwash_colormap,128);
		img2dout2 = NormalizeData(img2dout,colorwash_min,colorwash_max);
		img2dout2 = ColorRemap(img2dout2,MAPinColor);
		img2dout2 = img2dout2.*nanmask;
		h=image(xsout,ysout,img2dout2);
		set(h,'AlphaData',alpha,'hittest','off');
	end
	
% 	fillcolor = Check_MenuItem(handles.gui_handles.Dose_Display_Fill_Color_Menu_Item,0)==1;
	fillcolor = handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(idx);
% 	drawlines = Check_MenuItem(handles.gui_handles.Dose_Display_Isodose_Lines_Menu_Item,0)==1;
	drawlines = handles.gui_options.DoseDisplayOptions.display_isodose_lines(idx);
	if drawlines || fillcolor
		% display isodose lines
		MAPinColor = GetColormapByName(handles.gui_options.DoseDisplayOptions.isodose_line_colormap,128);
		current_colormap = get(gcf,'Colormap');
		current_clims = get(gca,'clim');
		set(gcf,'colormap',MAPinColor);
		set(gca,'clim',[0 max(isodose_lines)]);
		[C,h]=contour(gca,xsout,ysout,img2dout,isodose_lines);
		children = get(h,'children');
		set(h,'LineWidth',handles.gui_options.DoseDisplayOptions.display_isodose_line_width(idx));
		if fillcolor
			set(h,'hittest','off','fill','on');
		else
			set(h,'hittest','off');
		end
		set(gca,'clim',current_clims);
		set(gcf,'colormap',current_colormap);
		children = get(h,'children');
		for k = 1:length(children)
			cd=get(children(k),'CData');
			if ~isnan(cd(1))
				col = MAPinColor(floor(cd(1)*127/max(isodose_lines))+1,:);
				if drawlines
					set(children(k),'EdgeColor',col,'FaceColor',col,'FaceAlpha',alpha);
				else
					set(children(k),'EdgeColor','none','FaceColor',col,'FaceAlpha',alpha);
				end
			end
		end
		if drawlines && handles.gui_options.DoseDisplayOptions.display_isodose_line_label(idx) == 1
			[C,h]=contour(gca,xsout,ysout,img2dout,isodose_lines);
			
			th = clabel(C,h);
			
			set(th,'units','points','hittest','off','FontSize',handles.gui_options.DoseDisplayOptions.display_isodose_line_label_font_size(idx));
			set(th,'parent',gca);
			set(h,'visible','off');
			if fillcolor == 0
				for k = 1:length(th)
					val = get(th(k),'UserData');
					col = MAPinColor(floor(val*127/max(isodose_lines))+1,:);
					set(th(k),'Color',col);
				end
			end
		end
	end
end


