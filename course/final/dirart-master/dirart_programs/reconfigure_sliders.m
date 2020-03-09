function handles = reconfigure_sliders(handles)
% This is a supporting function of the deformable registration GUI.
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if isempty(handles.images(1).image)
	return;
end

EnableSliderControls(handles);
handles = set_display_geometry_limits(handles);

dim = size(handles.images(2).image);
if( length(dim) < 3 )
	handles = configure_sliders_for_2D(handles);
	return;
end

slider_step(1) = 1/(dim(1)-1);slider_step(2) = 5/(dim(1)-1);
set(handles.gui_handles.csno,'sliderstep',slider_step,'max',dim(1),'min',1,'Value',handles.gui_options.slidervalues(1,1));
set(handles.gui_handles.csmax,'String',num2str(dim(1)));
set(handles.gui_handles.csinput,'String',num2str(handles.gui_options.slidervalues(1,1)));

slider_step(1) = 1/(dim(2)-1);slider_step(2) = 5/(dim(2)-1);
set(handles.gui_handles.ssno,'sliderstep',slider_step,'max',dim(2),'min',1,'Value',handles.gui_options.slidervalues(1,2));
set(handles.gui_handles.ssmax,'String',num2str(dim(2)));
set(handles.gui_handles.ssinput,'String',num2str(handles.gui_options.slidervalues(1,2)));

slider_step(1) = 1/(dim(3)-1);slider_step(2) = 5/(dim(3)-1);
set(handles.gui_handles.tsno,'sliderstep',slider_step,'max',dim(3),'min',1,'Value',handles.gui_options.slidervalues(1,3));
set(handles.gui_handles.tsmax,'String',num2str(dim(3)));
set(handles.gui_handles.tsinput,'String',num2str(handles.gui_options.slidervalues(1,3)));

handles.gui_options.slidermins = [1 1 1];
handles.gui_options.slidermaxs = dim;

guidata(handles.gui_handles.figure1,handles);

return;

function handles = configure_sliders_for_2D(handles)
% 2D images, we shall disable all sliders
EnableSliderControls(handles);
dim = [size(handles.images(1).image) 1];
handles.gui_options.slidervalues(:,1) = 1;
handles.gui_options.slidervalues(:,2) = 1;
handles.gui_options.slidervalues(:,3) = 1;

set(handles.gui_handles.csno,'max',dim(1));
set(handles.gui_handles.ssno,'max',dim(2));
set(handles.gui_handles.tsno,'max',1);
set(handles.gui_handles.tsmax,'String','1');
guidata(handles.gui_handles.figure1,handles);
handles.gui_options.slidermins = [1 1 1];
handles.gui_options.slidermaxs = dim;
return;
