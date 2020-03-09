function vals = GetSliderValues(handles,imgidx)
%
% imgidx = 1, for image 1
% imgidx = 2, for image 2
% imgidx = 3, for the combined image
%
displaymode = handles.gui_options.display_mode(1,2);
[dim0,offs0] = GetImageDisplayDimensionAndOffsets(handles,displaymode);
[dim,offs] = GetImageDisplayDimensionAndOffsets(handles,imgidx);
vals = handles.gui_options.slidervalues(1,:) + offs0 - offs;
