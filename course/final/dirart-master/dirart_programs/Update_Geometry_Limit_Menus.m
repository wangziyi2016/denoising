function Update_Geometry_Limit_Menus(handles,idx)
%
%	Update_Geometry_Limit_Menus(handles,idx)
%

hs = handles.gui_handles;
menus = [hs.Option_Display_In_Regular_Image_Size_Menu_Item hs.Option_Display_In_Fixed_Image_Size_Menu_Item ...
	hs.Option_Display_In_Moving_Image_Size_Menu hs.Option_Display_In_Combined_Image_Size_Menu_Item ...
	hs.Option_Display_In_Intersected_Image_Size_Menu_Item];

set(menus,'checked','off');
set(menus(handles.gui_options.display_geometry_limit_mode(idx)),'checked','on');


