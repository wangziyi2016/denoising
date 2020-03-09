function handles = SetActivePanel(handles,idx)
%
%	handles = SetActivePanel(handles,idx)
%

handles = SetSliders(handles,idx);	% Update slider values
Update_Geometry_Limit_Menus(handles,idx);

if handles.gui_options.DoseDisplayOptions.display_isodose_lines(idx) == 1
	set(handles.gui_handles.Dose_Display_Isodose_Lines_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Dose_Display_Isodose_Lines_Menu_Item,'checked','off');
end

if handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(idx) == 1
	set(handles.gui_handles.Dose_Display_Fill_Color_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Dose_Display_Fill_Color_Menu_Item,'checked','off');
end

if handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(idx) == 1
	set(handles.gui_handles.Dose_Display_Colorwash_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Dose_Display_Colorwash_Menu_Item,'checked','off');
end

if handles.gui_options.Structure_Draw_Contour_Lines(idx) == 1
	set(handles.gui_handles.Display_Contour_Lines_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Display_Contour_Lines_Menu_Item,'checked','off');
end

if handles.gui_options.Structure_Fill_Color(idx) == 1
	set(handles.gui_handles.Fill_Structure_Color_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Fill_Structure_Color_Menu_Item,'checked','off');
end

if handles.gui_options.display_contour_in_own_view(idx) == 1
	set(handles.gui_handles.Display_Structure_In_Own_View_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Display_Structure_In_Own_View_Menu_Item,'checked','off');
end

if handles.gui_options.display_contour_1_in_all_views(idx) == 1
	set(handles.gui_handles.Options_Display_Structure_Contours_1_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Options_Display_Structure_Contours_1_Menu_Item,'checked','off');
end

if handles.gui_options.display_contour_2_in_all_views(idx) == 1
	set(handles.gui_handles.Options_Display_Structure_Contour_2_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Options_Display_Structure_Contour_2_Menu_Item,'checked','off');
end

if handles.gui_options.display_boundary_boxes(idx) == 1
	set(handles.gui_handles.Options_Draw_Box_For_Image_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Options_Draw_Box_For_Image_Menu_Item,'checked','off');
end

if handles.gui_options.display_NaN_boxes(idx) == 1
	set(handles.gui_handles.Options_Draw_Nan_Boundaries_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Options_Draw_Nan_Boundaries_Menu_Item,'checked','off');
end

if handles.gui_options.display_landmarks(idx) == 1
	set(handles.gui_handles.Option_Show_Land_Marks_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Option_Show_Land_Marks_Menu_Item,'checked','off');
end

if handles.gui_options.display_checkerboard_gridlines(idx) == 1
	set(handles.gui_handles.OptionsDisplayGridLinesMenuItem,'checked','on');
else
	set(handles.gui_handles.OptionsDisplayGridLinesMenuItem,'checked','off');
end

if handles.gui_options.display_image_in_color(idx) == 1
	set(handles.gui_handles.OptionsDisplayColorMenuItem,'checked','on');
else
	set(handles.gui_handles.OptionsDisplayColorMenuItem,'checked','off');
end

if handles.gui_options.display_checkerboard_in_color(idx) == 1
	set(handles.gui_handles.OptionsDisplayCheckerboardImageInColorMenuItem,'checked','on');
else
	set(handles.gui_handles.OptionsDisplayCheckerboardImageInColorMenuItem,'checked','off');
end

if handles.gui_options.display_colorbar(idx) == 1
	set(handles.gui_handles.OptionsDisplayColorbarMenuItem,'checked','on');
else
	set(handles.gui_handles.OptionsDisplayColorbarMenuItem,'checked','off');
end

if handles.gui_options.keep_aspect_ratio(idx) == 1
	set(handles.gui_handles.OptionsDisplayKeepAspectRatioMenuItem,'checked','on');
else
	set(handles.gui_handles.OptionsDisplayKeepAspectRatioMenuItem,'checked','off');
end

% Dose selection menu
menus = get(handles.gui_handles.Dose_Menu,'child');
N = length(menus);
if handles.gui_options.DoseDisplayOptions.dose_to_display(idx) <= N
	set(menus,'checked','off');
	if handles.gui_options.DoseDisplayOptions.dose_to_display(idx) > 0
		set(menus(N-handles.gui_options.DoseDisplayOptions.dose_to_display(idx)+1),'checked','on');
	end
end

for k =1:handles.gui_options.num_panels
	obj = findobj(handles.gui_handles.figure1,'tag',['label' num2str(k)]);
	if ~isempty(obj)
% 		fontsize = get(obj,'FontSize');
		if k == idx
			set(obj,'FontWeight','bold','FontSize',12,'Color',[1 0.5 0.5]);
		else
			set(obj,'FontWeight','normal','FontSize',10,'Color',[1 0 0]);
		end
	end
end


