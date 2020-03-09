function EnableSliderControls(handles)
%
%
%
dim = size(handles.images(2).image);
if( length(dim) < 3 )
	set(handles.gui_handles.tsno,'Enable','Off');
	set(handles.gui_handles.ssno,'Enable','Off');
	set(handles.gui_handles.csno,'Enable','Off');
	set(handles.gui_handles.tsmin,'Enable','Off');
	set(handles.gui_handles.tsmax,'Enable','Off');
	set(handles.gui_handles.tsinput,'Enable','Off');
	set(handles.gui_handles.csmin,'Enable','Off');
	set(handles.gui_handles.csmax,'Enable','Off');
	set(handles.gui_handles.csinput,'Enable','Off');
	set(handles.gui_handles.ssmin,'Enable','Off');
	set(handles.gui_handles.ssmax,'Enable','Off');
	set(handles.gui_handles.ssinput,'Enable','Off');
	set(handles.gui_handles.transverse_text,'Enable','Off');
	set(handles.gui_handles.coronal_text,'Enable','Off');
	set(handles.gui_handles.sagittal_text,'Enable','Off');
else
	set(handles.gui_handles.tsno,'Enable','On');
	set(handles.gui_handles.ssno,'Enable','On');
	set(handles.gui_handles.csno,'Enable','On');
	set(handles.gui_handles.tsmin,'Enable','On');
	set(handles.gui_handles.tsmax,'Enable','On');
	set(handles.gui_handles.tsinput,'Enable','On');
	set(handles.gui_handles.csmin,'Enable','On');
	set(handles.gui_handles.csmax,'Enable','On');
	set(handles.gui_handles.csinput,'Enable','On');
	set(handles.gui_handles.ssmin,'Enable','On');
	set(handles.gui_handles.ssmax,'Enable','On');
	set(handles.gui_handles.ssinput,'Enable','On');
	set(handles.gui_handles.transverse_text,'Enable','On');
	set(handles.gui_handles.coronal_text,'Enable','On');
	set(handles.gui_handles.sagittal_text,'Enable','On');
end
