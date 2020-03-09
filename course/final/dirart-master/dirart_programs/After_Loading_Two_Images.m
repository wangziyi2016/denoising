function handles = After_Loading_Two_Images(handles)
%
%
%
img1 = handles.images(1).image;
img2 = handles.images(2).image;

handles.images(1).class = class(img1);
handles.images(2).class = class(img2);
img1 = single(img1);
img1 = max(img1,0);
img2 = single(img2);
img2 = max(img2,0);
maxv1 = max(img1(:));
maxv = max(maxv1,max(img2(:)));

handles.images(1).image = img1;
handles.images(2).image = img2;
clear img1 img2;

handles = Align_Images_After_Loading(handles);

handles.reg.images_setting.max_intensity_value = maxv;
handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/4;
handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
% handles.gui_options.window_center = ones(1,7)*1000;
% handles.gui_options.window_width = ones(1,7)*1000;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;

if ndims(handles.images(1).image) == 2
	handles.gui_options.display_mode(1,:) = [3 1];
	handles.gui_options.display_mode(2,:) = [3 2];
else
	handles.gui_options.display_mode(1,:) = [1 1];
	handles.gui_options.display_mode(2,:) = [1 2];
end
handles.gui_options.display_boundary_boxes(:) = 1;
handles.gui_options.display_contour_in_own_view(:) = 1;
handles.gui_options.display_contour_1_in_all_views(:) = 0;
handles.gui_options.display_contour_2_in_all_views(:) = 0;
handles = InitSliderPosition(handles);
handles = reconfigure_sliders(handles);

if strcmp(handles.images(1).type,'MVCT SCAN') == 1
	handles.images(1).image = preprocess_MVCT_image(handles.images(1).image,1);
end
if strcmp(handles.images(2).type,'MVCT SCAN') == 1
	handles.images(2).image = preprocess_MVCT_image(handles.images(2).image,1);
end

if ndims(handles.images(1).image) > 2
    handles = Crop_Image_3D(handles,1);
end
handles = InitSliderPosition(handles);
handles = reconfigure_sliders(handles);


handles = Resample_Images_After_Loading(handles);

handles = Logging(handles,'\tImage #1 size = [%s]', num2str(size(handles.images(1).image),'%d '));
handles = Logging(handles,'\tImage #2 size = [%s]', num2str(size(handles.images(2).image),'%d '));

% handles.reg.images_setting.image_offsets = round((size(handles.images(1).image)-size(handles.images(2).image))/2);	% Align the images in the center
% handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;

handles = InitSliderPosition(handles);
handles = reconfigure_sliders(handles);

Save_Images_To_Temp_Folder(handles,0);
setinfotext('Both images are successfully loaded'); drawnow;

handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);
handles = RemoveUndoInfo(handles);
handles = Clear_Results(handles);

RefreshDisplay(handles);
guidata(handles.gui_handles.figure1,handles);


