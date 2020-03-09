function handles = configure_sliders(handles,curStage,lastStage)
%{
A supporting function used by deformable registration GUI
This function will update the sliders according to the current image dimensions.

Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%}

if isempty(handles.images(1).image)
	return;
end

handles = set_display_geometry_limits(handles);
dim = GetImageDisplayDimensionAndOffsets(handles);
if exist('curStage','var')
	ratio = 2^(lastStage - curStage);
else
	oldmax = get(handles.gui_handles.csno,'max');
	ratio = single(dim(1))/oldmax;
end

if length(dim) < 3 || dim(3) == 1
	handles = configure_sliders_for_2D(handles);
	return;
end

EnableSliderControls(handles);
idx = handles.gui_options.current_axes_idx;

oldval = handles.gui_options.slidervalues;
handles.gui_options.slidervalues = round(oldval*ratio);

slider_step(1) = 1/(dim(1)-1);slider_step(2) = 5/(dim(1)-1);
set(handles.gui_handles.csno,'sliderstep',slider_step,'max',dim(1),'min',1,'Value',handles.gui_options.slidervalues(idx,1));
set(handles.gui_handles.csmax,'String',num2str(dim(1)));
set(handles.gui_handles.csinput,'String',num2str(handles.gui_options.slidervalues(idx,1)));

slider_step(1) = 1/(dim(2)-1);slider_step(2) = 5/(dim(2)-1);
set(handles.gui_handles.ssno,'sliderstep',slider_step,'max',dim(2),'min',1,'Value',handles.gui_options.slidervalues(idx,2));
set(handles.gui_handles.ssmax,'String',num2str(dim(2)));
set(handles.gui_handles.ssinput,'String',num2str(handles.gui_options.slidervalues(idx,2)));

if dim(3) > 1
    slider_step(1) = 1/(dim(3)-1);slider_step(2) = 5/(dim(3)-1);
    set(handles.gui_handles.tsno,'sliderstep',slider_step,'max',dim(3),'min',1,'Value',handles.gui_options.slidervalues(idx,3));
    set(handles.gui_handles.tsmax,'String',num2str(dim(3)));
    set(handles.gui_handles.tsinput,'String',num2str(handles.gui_options.slidervalues(idx,3)));
end

handles.gui_options.slidermins = [1 1 1];
handles.gui_options.slidermaxs = dim;

guidata(handles.gui_handles.figure1,handles);

return;

function handles = configure_sliders_for_2D(handles)
% 2D images, we shall disable all sliders
dim = GetImageDisplayDimensionAndOffsets(handles);

handles.gui_options.slidervalues(:,1) = 1;
handles.gui_options.slidervalues(:,2) = 1;
handles.gui_options.slidervalues(:,3) = 1;

set(handles.gui_handles.csno,'max',dim(1));
set(handles.gui_handles.ssno,'max',dim(2));

guidata(handles.gui_handles.figure1,handles);
return;
