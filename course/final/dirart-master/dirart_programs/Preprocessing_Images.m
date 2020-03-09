function handles = Preprocessing_Images(handles,action)
%
%	handles = Preprocessing_Images(handles,action)
%
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

preproecessing_on_images(1) = Check_MenuItem(handles.gui_handles.Apply_2_Image_1_Menu_Item,0);
preproecessing_on_images(2) = Check_MenuItem(handles.gui_handles.Apply_2_Image_2_Menu_Item,0);

modified = 0;

switch lower(action)
	case 'bowel_gas_painting'
		button=questdlg('Use NaN to patch gas pocket?', 'Use NaN to patch','Yes','No','Yes');
	case 'nonlinear_histogram_adjustment'
		preproecessing_on_images = [1 1];
		x = [0  650  800  1000  1050  1200 1300  1500 2000];
		y = [0  0.1  0.2  0.35  0.5   0.6  0.65  0.9  1]*2000;
		map = [x;y]';
	case 'nonlinear_histogram_adjustment_for_lung'
		preproecessing_on_images = [1 1];
end


for k = 1:2
	if preproecessing_on_images(k) == 1
		switch lower(action)
			case 'smooth'
				setinfotext(sprintf('Smoothing image #%d ...',k));
				% 	handles.images(1).image = lowpass3d(handles.images(1).image,1);
				handles.images(k).image = lowpass3d(handles.images(k).image,[0.3 0.3 0]);
				handles = Logging(handles,'Image #%d is smoothed',k);
			case 'edge_preserve_smooth'
				setinfotext(sprintf('Edge preserve smoothing image #%d ...',k));
%                 filterno = 13;
                filterno = 2;
				if sum(isnan(handles.images(k).image)) == 0
					handles.images(k).image = denoise3in2(filterno,handles.images(k).image);
				else
					nanmask = ~isnan(handles.images(k).image);
					img1 = handles.images(k).image;
					img1(isnan(img1)) = 0;
% 					img1 = denoise3in2(filterno,img1);
					img1 = denoise3in2(filterno,img1,1,1,2);
					img1(~nanmask) = nan;
					handles.images(k).image = img1;
				end
				handles = Logging(handles,'Image #%d is edge-preserving smoothed',k);
			case 'window_level_transform'
				setinfotext(sprintf('Window level transform image #%d ...',k));
				handles.images(k).image = WindowTransformImageIntensity(handles.images(k).image,handles.gui_options.window_center(1),handles.gui_options.window_width(1));
				handles = Logging(handles,'Image #%d window level transformed using center = %d, width = %d',k,handles.gui_options.window_center(1),handles.gui_options.window_width(1));
			case 'padding'
				handles.images(k).image = padImage(handles.images(k).image,handles.reg.Multigrid_Stages-1,'replicate');
				handles = Logging(handles,'Image #%d is padded',k);
			case 'normalize'
				handles.images(k).image = NormalizeImageSize(handles.images(k).image,handles.reg.Multigrid_Stages-1);
				handles = Logging(handles,'Image #%d size is normalized',k);
			case 'flip_ap'
				handles.images(k).image = flipdim(handles.images(k).image,1);
				handles = Logging(handles,'Image #%d is flipped in AP',k);
			case 'flip_lr'
				handles.images(k).image = flipdim(handles.images(k).image,2);
				handles = Logging(handles,'Image #%d is flipped in LR',k);
			case 'flip_si'
				handles.images(k).image = flipdim(handles.images(k).image,3);
				handles = Logging(handles,'Image #%d is flipped in LR',k);
			case 'kv_2_mv_remap'
				handles.images(k).image = remapKV2MV(handles.images(k).image);
				handles = Logging(handles,'Applying KV to MV remap on image #%d',k);
			case 'bowel_gas_painting'
				if strcmp(button,'Yes')==1
					handles.images(k).image = paint_gas_pocket(handles.images(k).image,[],[],nan);
				else
					handles.images(k).image = paint_gas_pocket(handles.images(k).image);
				end
				handles = Logging(handles,'Applying gas pocket paiting on image #%d',k);
			case 'nonlinear_histogram_adjustment'
				handles.images(k).image = Nonlinear_Histogram_Adjustment(handles.images(k).image,map);
				handles = Logging(handles,'Applying nonlinear HE on image #%d',k);
			case 'nonlinear_histogram_adjustment_for_lung'
				handles.images(k).image = Nonlinear_Histogram_Adjustment_For_Lung(handles.images(k).image);
				handles = Logging(handles,'Nonlinear HE for both images for lung on image #%d',k);
            case 'subtract_local_average_intensity'
				handles.images(k).image = subtract_image_local_average(handles.images(k).image);
				handles = Logging(handles,'Subtract local image average on image #%d',k);
		end
		modified = 1;
	end
end

if modified == 1
	switch lower(action)
		case 'smooth'
			setinfotext('Images has been smoothed by Gaussian low pass filter with sigma = 0.3');
		case 'edge_preserve_smooth'
			setinfotext('Images has been smoothed by bilateral / edge preserving filter');
		case 'window_level_transform'
			handles.reg.images_setting.max_intensity_value = max(max(handles.images(1).image(:)),max(handles.images(2).image(:)));
			handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
			handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value;
			reg3dgui_global_windows_centers = handles.gui_options.window_center;
			reg3dgui_global_windows_widths = handles.gui_options.window_width;
			setinfotext('Window level transform has been applied to correct images intensity');
		case 'padding'
			setinfotext('Images have been padded and they are ready for registration');
		case 'normalize'
			setinfotext('Images sizes have been normalized and they are ready for registration');
		case 'flip_ap'
			setinfotext('Images are flipped in AP direction');
		case 'flip_lr'
			setinfotext('Images are flipped in LR direction');
		case 'flip_si'
			setinfotext('Images are flipped in SI direction');
		case 'kv_2_mv_remap'
			setinfotext('Image intensity has been converted from KVCT space to MVCT space');
		case 'bowel_gas_painting'
			setinfotext('Bowel gas pockets have been found and painted.');
		case 'nonlinear_histogram_adjustment'
			setinfotext('Nonlinear adjusted finished');
			handles = Use_Default_Window_Level(handles);
		case 'nonlinear_histogram_adjustment_for_lung'
			setinfotext('Nonlinear adjusted finished');
			handles = Use_Default_Window_Level(handles);
        case 'subtract_local_average_intensity'
			setinfotext('subtract_local_average_intensity adjusted finished');
			handles = Use_Default_Window_Level(handles);
		otherwise
			setinfotext(sprintf('Unknown image preprocessing action: %s',action));
	end
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

return;
