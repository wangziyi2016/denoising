function start_registration_from_menu(method,handles)
%
%
%
if Check_Image_Dimensions(handles,1) == 0
	setinfotext('Cannot start registration before image dimension requirement is met.');
	return;
end
	
handles = RemoveUndoInfo(handles);
Save_Images_To_Temp_Folder(handles,1);

setinfotext('Starting registration ...');
%if isfield(handles,'image_filenames')
[pathstr,namestr] = fileparts(handles.images(1).filename);
% dim = size(handles.images(2).image);
set(handles.gui_handles.abortbutton,'enable','on');
set(handles.gui_handles.pausebutton,'enable','on');
set(handles.gui_handles.Pause_Registration_Menu_Item,'enable','on');
set(handles.gui_handles.Abort_Registration_Menu_Item,'enable','on');
set(handles.gui_handles.Stop_Current_Stage_Menu_Item,'enable','on');
set(handles.gui_handles.Start_Registration_Menu_Item,'enable','off');
force_reverse_consistency = strcmpi(handles.reg.registration_framework,'consistency');
smoothing_settings = [handles.reg.smoothing_in_iteration handles.reg.smoothing_after_pass];

handles = Logging(handles,'Starting registration at %s', datestr(now));
handles = Logging(handles,'\tMethod = [%d]', method);
handles = Logging(handles,'\tInverse consistency = [%d]', force_reverse_consistency);
handles = Logging(handles,'\tSmoothing setting = [%s]', num2str(smoothing_settings,'%g  '));
handles = Logging(handles,'\tNum of stages = [%d]', handles.reg.Multigrid_Stages);
handles = Logging(handles,'\tMultigrid filter type = [%d]', handles.reg.multigrid_filter_type);

img1 = handles.images(1).image;

if Check_MenuItem(handles.gui_handles.Use_Current_Results_and_Continue_Menu_Item,0) == 1 && isfield(handles,'mvx') && ~isempty(handles.reg.dvf.x)
	Use_Current_Result_And_Continue = 1;
else
	Use_Current_Result_And_Continue = 0;
end

% Not_Deform_Regions = Check_MenuItem(handles.gui_handles.Not_Deform_Regions_Menu_Item,0);

try
	if Use_Current_Result_And_Continue == 1
		handles = Logging(handles,'\tContinuing previous registration results');

		fprintf('\n\nUsing previous registration results and continue ...\n\n');
		img1_save = handles.images(1).image;
		mvy_save = handles.reg.dvf.y;
		mvx_save = handles.reg.dvf.x;
		mvz_save = handles.reg.dvf.z;
% 		if ~isempty(handles.images(1).structure_mask)
% 			structure_masks_save = handles.images(1).structure_mask;
% 		end

		if ~isequal(size(mvy_save),size(handles.images(1).image))
			[mvyL,mvxL,mvzL] = expand_motion_field(mvy_save,mvx_save,mvz_save,mysize(img1),handles.reg.images_setting.image_current_offsets,10);
			disp('Computing i1vx ...');
			img1 = move3dimage(img1,mvyL,mvxL,mvzL);

% 			if Check_MenuItem(handles.gui_handles.Regional_Smoothing_Menu_Item,0) == 1 && Not_Deform_Regions == 0 && ~isempty(handles.images(1).structure_mask)
% 				disp('Computing deformed structure masks ...');
% 				handles.images(1).structure_mask = deform_structure_masks(handles.images(1).structure_mask,mvyL,mvxL,mvzL);
% 			end
			clear mvyL mvxL mvzL;
		else
			disp('Computing i1vx ...');
			img1 = move3dimage(img1,mvy_save,mvx_save,mvz_save);
% 			if Check_MenuItem(handles.gui_handles.Regional_Smoothing_Menu_Item,0) == 1 && Not_Deform_Regions == 0 && ~isempty(handles.images(1).structure_mask)
% 				disp('Computing deformed structure masks ...');
% 				handles.images(1).structure_mask = deform_structure_masks(handles.images(1).structure_mask,mvy_save,mvx_save,mvz_save);
% 			end
		end

% 		if ~isempty(handles.images(1).structure_mask)
% 			guidata(handles.gui_handles.figure1,handles);
% 		end
	end

	ratio = handles.images(1).voxelsize / min(handles.images(1).voxelsize);
	if force_reverse_consistency == 1 && any(method == [1 2 4 6 7 8 11 12 17 18 19 20 21 30])
		handles = Logging(handles,'\tUsing inverse consistency framework');
		guidata(handles.gui_handles.figure1,handles);
		[mvy,mvx,mvz] = multigrid_7_reverse_consistent(method,img1,handles.images(2).image,ratio,handles.reg.Multigrid_Stages,1,handles.gui_handles.figure1,handles.reg.Save_Temp_Results+handles.reg.Log_Output*2,[],namestr,smoothing_settings,handles.reg.multigrid_filter_type);
% 	elseif Check_MenuItem(handles.gui_handles.Regional_Smoothing_Menu_Item,0) == 1 && ~isempty(handles.images(1).structure_mask) && isequal(size(handles.images(1).image),size(handles.images(1).structure_mask))
% 		handles = Logging(handles,'\tUsing regional smoothing framework');
% 		guidata(handles.gui_handles.figure1,handles);
% 		if isfield(handles.reg,'expanded_structure_masks') && ~isempty(handles.reg.expanded_structure_masks)
% 			if Check_MenuItem(handles.gui_handles.Use_Current_Results_and_Continue_Menu_Item,0) == 0
% 				structure_masks_save = handles.images(1).structure_mask;
% 			end
% 			[mvy,mvx,mvz] = multigrid_regional_smoothing(method,img1,handles.images(2).image,handles.reg.expanded_structure_masks,ratio,handles.reg.Multigrid_Stages,1,handles.gui_handles.figure1,handles.reg.Save_Temp_Results+handles.reg.Log_Output*2,[],namestr,smoothing_settings,0,handles.reg.multigrid_filter_type);
% 			if isequal(size(mvy),size(handles.images(2).image)) && isfield(handles.reg,'expanded_structure_masks')
% 				handles = guidata(handles.gui_handles.figure1);	% Get the new results
% 				handles.images(1).structure_mask = structure_masks_save;
% 				guidata(handles.gui_handles.figure1,handles);
% 			end
% 		else
% 			[mvy,mvx,mvz] = multigrid_regional_smoothing(method,img1,handles.images(2).image,handles.images(1).structure_mask,ratio,handles.reg.Multigrid_Stages,1,handles.gui_handles.figure1,handles.reg.Save_Temp_Results+handles.reg.Log_Output*2,[],namestr,smoothing_settings,0,handles.reg.multigrid_filter_type);
% 		end
	else
		handles = Logging(handles,'\tUsing regular multigrid framework');
		guidata(handles.gui_handles.figure1,handles);
		[mvy,mvx,mvz] = multigrid_7(method,img1,handles.images(2).image,[],ratio,handles.reg.Multigrid_Stages,1,handles.gui_handles.figure1,handles.reg.Save_Temp_Results+handles.reg.Log_Output*2,[],namestr,smoothing_settings,handles.reg.Intensity_Modulation*2,handles.reg.multigrid_filter_type);
	end

	handles = guidata(handles.gui_handles.figure1);	% Get the new results

	if Use_Current_Result_And_Continue == 1
		handles = Logging(handles,'\tComposing new results with previous results');
		disp('Composing new results with previous results ...');
		[mvy,mvx,mvz] = compose_motion_field(mvy_save,mvx_save,mvz_save,mvy,mvx,mvz);
		handles.reg.dvf.y = mvy;
		handles.reg.dvf.x = mvx;
		handles.reg.dvf.z = mvz;
		handles.images(1).image_deformed = move3dimage(img1_save,mvy,mvx,mvz,[],handles.reg.images_setting.image_current_offsets);
		handles.images(1).image = img1_save;

% 		if ~isempty(handles.images(1).structure_mask)
% 			handles.images(1).structure_mask = structure_masks_save;
% 		end

		Check_MenuItem(handles.gui_handles.Use_Current_Results_and_Continue_Menu_Item,1);	% Turn the option off

		guidata(handles.gui_handles.figure1,handles);

		RefreshDisplay(handles);

		fprintf('\n\nResults are composed with previous registration results.\n\n');
	end
	handles = Logging(handles,'\tRegistration is finished at %s', datestr(now));
	setinfotext('Registration finished');
catch ME
	print_lasterror(ME);
	handles = Load_Images_From_Temp_Folder(handles,1);
	RefreshDisplay(handles);
	setinfotext('Error happened, registration is not finished');
end

guidata(handles.gui_handles.figure1,handles);

set(handles.gui_handles.abortbutton,'enable','off');
set(handles.gui_handles.pausebutton,'enable','off');
set(handles.gui_handles.Start_Registration_Menu_Item,'enable','on');
set(handles.gui_handles.Pause_Registration_Menu_Item,'enable','off');
set(handles.gui_handles.Abort_Registration_Menu_Item,'enable','off');
set(handles.gui_handles.Stop_Current_Stage_Menu_Item,'enable','off');

