function handles = After_Loading_Saved_Project(handles)
%
%	After_Loading_Saved_Project(handles)
%
handles = CheckSettingParameters(handles);
handles = RecoverImageAlignmentPoints(handles);

handles = InitSliderPosition(handles);
handles = reconfigure_sliders(handles);
handles.gui_options.current_axes_idx = 1;
handles.gui_options.button_down_axis_idx = 1;
handles.gui_options.DoseDisplayOptions.dose_to_display(:) = 0;
GenerateDoseMenu(handles);
handles = SetActivePanel(handles,1);
Save_Images_To_Temp_Folder(handles,0);
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
if length(handles.gui_options.window_center) == 1
	handles.gui_options.window_center = ones(1,7)*handles.gui_options.window_center;
	handles.gui_options.window_width = ones(1,7)*handles.gui_options.window_width;
	reg3dgui_global_windows_centers = handles.gui_options.window_center;
	reg3dgui_global_windows_widths = handles.gui_options.window_width;
	RefreshDisplay(handles);
else
	reg3dgui_global_windows_centers = handles.gui_options.window_center;
	reg3dgui_global_windows_widths = handles.gui_options.window_width;
% 	handles = Use_Default_Window_Level(handles);
end


handles = set_display_geometry_limits(handles);
Update_Geometry_Limit_Menus(handles,1);

currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir)
	
	N = length(handles.ART.structures);
	if N > 0
		for k = 1:N
			struct1 = GetElement(handles.ART.structures,k);
			if isfield(struct1,'meshRep') && struct1.meshRep == 1
				calllib('libMeshContour','loadSurface',struct1.strUID,struct1.meshS);
			elseif ~isfield(struct1,'meshRep')
				if ~isfield(struct1,'meshS')||isempty(struct1.meshS)
					struct1.meshRep = 0;
					struct1.meshS = [];
				else
					struct1.meshRep = 1;
				end
				handles.ART.structures{k} = struct1;
			end
		end
	end
	
	cd(currDir);
else
	uiwait(msgbox('Cannot load the LibMeshContour library which supports 32-bit MATLAB only for now. You won''t be able to use some DIRART contour processing features.','warning','warn'));
end

handles = After_Loading_Project_Set_GUI(handles);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
setinfotext('Entire Data Set is loaded');




