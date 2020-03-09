function handles = After_Loading_Project_Set_GUI(handles)
%
%	handles = After_Loading_Project_Set_GUI(handles)
%

if handles.gui_options.lock_between_display == 1
	set(handles.gui_handles.GUIOptions_Lock_Display_Menu_Item,'checked','on');
else
	set(handles.gui_handles.GUIOptions_Lock_Display_Menu_Item,'checked','off');
end

if handles.reg.Save_Temp_Results == 1
	set(handles.gui_handles.Save_Temp_Results_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Save_Temp_Results_Menu_Item,'checked','off');
end

if handles.reg.Log_Output == 1
	set(handles.gui_handles.Enable_Log_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Enable_Log_Menu_Item,'checked','off');
end

if handles.reg.Generate_Reverse_Consistent_Motion_Field == 1
	set(handles.gui_handles.Generate_Reverse_Motion_Field_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Generate_Reverse_Motion_Field_Menu_Item,'checked','off');
end

if handles.reg.Intensity_Modulation == 1
	set(handles.gui_handles.Intensity_Modulation_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Intensity_Modulation_Menu_Item,'checked','off');
end

if handles.reg.Use_Both_Image_Gradients == 1
	set(handles.gui_handles.Use_Both_Image_Gradients_Menu_Item,'checked','on');
else
	set(handles.gui_handles.Use_Both_Image_Gradients_Menu_Item,'checked','off');
end

handles = SetRegAlgorithmSelection(handles);
handles = SetActivePanel(handles,handles.gui_options.current_axes_idx);


