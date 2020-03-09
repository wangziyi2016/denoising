function handles = Use_Default_Window_Level(handles)
max_intensity_value = max(max(handles.images(1).image(:)),max(handles.images(2).image(:)));
handles.gui_options.window_width = ones(1,7)*max_intensity_value;
handles.gui_options.window_center = ones(1,7)*max_intensity_value/2;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
ConditionalRefreshDisplay(handles,[1:9 19 20]);
