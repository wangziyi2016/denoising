function handles = SetSlidersValueForOtherDisplays(handles,idx,viewdir)
%
% Update the slider values for other display if the value of one display is
% changed
%
if ~exist('idx','var')
	idx = handles.gui_options.current_axes_idx;
end

if ~exist('viewdir','var')
	viewdir = handles.gui_options.display_mode(idx,1);
end

displaymode = handles.gui_options.display_mode(idx,2);
[dim0,offs0] = GetImageDisplayDimensionAndOffsets(handles,displaymode);

for k = 1:7
	if k ~= idx
		[dim,offs] = GetImageDisplayDimensionAndOffsets(handles,handles.gui_options.display_mode(k,2));
		handles.gui_options.slidervalues(k,viewdir) = handles.gui_options.slidervalues(idx,viewdir) + offs0(viewdir) - offs(viewdir);
	end
end

