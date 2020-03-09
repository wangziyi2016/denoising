function [handles,modified] = Define_3D_ROI(handles,displaymode,confirm)
%
%	[handles,modified] = Define_3D_ROI(handles,displaymode,confirm)
%
%	confirm =	1	- ask confirmation
%				2	- retry until it is confirmed
%
while 1
	[handles,modified,confirmed] = Define_3D_ROI_inter(handles,displaymode,confirm);
	if confirm < 2 || confirmed == 1 || modified == 0
		break;
	end
end
return;

function [handles,modified,confirmed] = Define_3D_ROI_inter(handles,displaymode,confirm)
confirmed = 0;
modified = 0;
handles.gui_options_save = handles.gui_options;
try
	handles.gui_options.display_mode(1,:) = [1 displaymode];
	handles.gui_options.display_mode(2,:) = [2 displaymode];
	handles.gui_options.display_mode(3,:) = [3 displaymode];
	handles.gui_options.display_enabled = [1 1 1 0 0 0 0];
	handles = InitSliderPosition(handles);
	handles = reconfigure_sliders(handles);
	handles.gui_options.gui_lock = 1;
	handles.gui_options.display_maxprojection = 1;
	handles.gui_options.draw_3D_ROI = 1;
	handles.gui_options.current_axes_idx = 1;
	handles.gui_options.alphas(1:3) = [1 0.5 0.5];
	guidata(handles.gui_handles.figure1,handles);
	
	modified = 0;

	vecs = GetImageCoordinateVectors(handles,WhichImageCoordinateToUse(displaymode));
	if isempty(handles.gui_options.ROI3D)
		handles.gui_options.ROI3D = zeros(3,2);
		handles.gui_options.ROI3D(1,:) = GetLimitsFromVector(vecs.ys)';
		handles.gui_options.ROI3D(2,:) = GetLimitsFromVector(vecs.xs)';
		handles.gui_options.ROI3D(3,:) = GetLimitsFromVector(vecs.zs)';
	end
% 	RefreshDisplay(handles);
	handles.gui_options.display_destination = 2;
	hfig1 = update_display(handles,1);
	set(hfig1,'name','Use mouse to draw a ROI box, right click to cancel','windowstyle','modal');

	set(handles.gui_handles.axes_handles(1:3),'UIContextMenu','');

	setinfotext('Please use mouse to drag ROI box in display #1')
	title('Use mouse to draw a ROI box, right click to cancel');
	[x1,y1,x2,y2] = GetCropBoundaries(gca,0);
	if ~isempty(x1)
		[x1,x2] = CheckVectorAgainstLimits(x1,x2,GetLimitsFromVector(vecs.xs));
		[y1,y2] = CheckVectorAgainstLimits(y1,y2,GetLimitsFromVector(vecs.zs));
		handles.gui_options.ROI3D(2,1) = x1;
		handles.gui_options.ROI3D(2,2) = x2;
		handles.gui_options.ROI3D(3,1) = y1;
		handles.gui_options.ROI3D(3,2) = y2;
		modified = 1;
	end

	handles.gui_options.alphas(1:3) = [0.5 1 0.5];
	handles.gui_options.current_axes_idx = 2;
% 	RefreshDisplay(handles);
	setinfotext('Please use mouse to drag ROI box in display #2')
	hfig2 = update_display(handles,2);
	set(hfig2,'name','Use mouse to draw a ROI box, right click to cancel','windowstyle','modal');
	title('Use mouse to draw a ROI box, right click to cancel');
	[x1,y1,x2,y2] = GetCropBoundaries(gca,0);
	if ~isempty(x1)
		[x1,x2] = CheckVectorAgainstLimits(x1,x2,GetLimitsFromVector(vecs.ys));
		[y1,y2] = CheckVectorAgainstLimits(y1,y2,GetLimitsFromVector(vecs.zs));
		handles.gui_options.ROI3D(1,1) = x1;
		handles.gui_options.ROI3D(1,2) = x2;
		handles.gui_options.ROI3D(3,1) = y1;
		handles.gui_options.ROI3D(3,2) = y2;
		modified = 1;
	end

	handles.gui_options.alphas(1:3) = [0.5 0.5 1];
	handles.gui_options.current_axes_idx = 3;
% 	RefreshDisplay(handles);
	hfig3 = update_display(handles,3);
	set(hfig3,'name','Use mouse to draw a ROI box, right click to cancel','windowstyle','modal');
	title('Use mouse to draw a ROI box, right click to cancel');
	
	setinfotext('Please use mouse to drag ROI box in display #3')
% 	[x1,y1,x2,y2] = GetCropBoundaries(handles.gui_handles.axes_handles(3),0);
	[x1,y1,x2,y2] = GetCropBoundaries(gca,0);
	if ~isempty(x1)
		[x1,x2] = CheckVectorAgainstLimits(x1,x2,GetLimitsFromVector(vecs.xs));
		[y1,y2] = CheckVectorAgainstLimits(y1,y2,GetLimitsFromVector(vecs.ys));
		handles.gui_options.ROI3D(2,1) = x1;
		handles.gui_options.ROI3D(2,2) = x2;
		handles.gui_options.ROI3D(1,1) = y1;
		handles.gui_options.ROI3D(1,2) = y2;
		modified = 1;
	end

	handles.gui_options.display_destination = 1;
	if modified == 1
% 		RefreshDisplay(handles);
		ROI3D = handles.gui_options.ROI3D;
		handles.gui_options = handles.gui_options_save;
		handles = rmfield(handles,'gui_options_save');
		if ~isequal(handles.gui_options.ROI3D,ROI3D)
			if confirm > 0
				ButtonName=questdlg('Is the ROI acceptable?', ...
					'Image ROI definition','No','Yes','Yes');
				if strcmp(ButtonName,'Yes') == 1
					handles.gui_options.ROI3D = ROI3D;
					confirmed = 1;
				end
			else
				handles.gui_options.ROI3D = ROI3D;
			end
		end
	else
		handles.gui_options = handles.gui_options_save;
		handles = rmfield(handles,'gui_options_save');
	end
	close(hfig1);
	close(hfig2);
	close(hfig3);
catch ME
    print_lasterror(ME);
end
set(handles.gui_handles.axes_handles(1:3),'UIContextMenu',handles.gui_handles.Popup_Menu_View_Selection_2);

handles.gui_options.display_destination = 1;
handles.gui_options.alphas(1:3) = [1 1 1];
handles.gui_options.display_maxprojection = 0;
handles.gui_options.draw_3D_ROI = 0;
guidata(handles.gui_handles.figure1,handles);
% RefreshDisplay(handles);

