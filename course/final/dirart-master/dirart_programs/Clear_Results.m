function handles = Clear_Results(handles)
%
%	handles = Clear_Results(handles)
%
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;

handles.images(1).image_deformed = [];
handles.images(2).image_deformed = [];
handles.reg.dvf.x = [];
handles.reg.dvf.y = [];
handles.reg.dvf.z = [];

handles.reg.idvf.x = [];
handles.reg.idvf.y = [];
handles.reg.idvf.z = [];

handles.reg=rmfield_from_struct(handles.reg,{'mvx_iteration','mvy_iteration','mvz_iteration'});
handles.reg=rmfield_from_struct(handles.reg,{'mvx_pass','mvy_pass','mvz_pass','jacobina','inverse_consistency_errors'});
handles.reg = rmfield_from_struct(handles.reg,'deformed_structure_masks');

handles = reconfigure_sliders(handles);
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
handles.reg.images_setting.max_intensity_value = max(max(handles.images(1).image(:)),max(handles.images(1).image(:)));
handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value;

reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;

