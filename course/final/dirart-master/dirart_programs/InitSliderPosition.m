function handles = InitSliderPosition(handles)
%
%	handles = InitSliderPosition(handles)
%
handles.gui_options.slidervalues = repmat(round(mysize(handles.images(2).image)/2),7,1);
for idx = 1:7
	if handles.gui_options.display_enabled(idx) > 0
		displaymode = handles.gui_options.display_mode(idx,2);
		[dim,offs] = GetImageDisplayDimensionAndOffsets(handles,displaymode);
		if max(abs(offs)) > 0
			handles.gui_options.slidervalues(idx,:) = handles.gui_options.slidervalues(idx,:) - offs;
		end
		handles = SetSliders(handles,idx);
	end
end
