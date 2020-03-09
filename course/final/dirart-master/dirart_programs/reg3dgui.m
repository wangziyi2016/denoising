function varargout = reg3dgui(varargin)
%
% Deformation Image Registration Tool
% Programed by Deshan Yang, 2007, Washington University in St Louis
%
% Usage:
% 1:  reg3dgui,   with no arguments
% 2:  reg3dgui(img1,img2), where img1 is the moving image, and img2 is the
%     fixed image
% 3:  reg3dgui(img1_filename,img2_filename)
% 4.  reg3dgui(img1,img2,other_arguments_pairs)
%     Other arguments pairs: giving the name of the argument, then the
%     argument
%       'i1vx' - the deformed moving image
%       'i2vx' - the deformed image #2, used in inverse consistency
%       algorithms
%       'mvx'  - motion field on x axis
%       'mvy'  - motion field on y axis
%       'mvz'  - motion field on z axis
%       'mvs'  - motion fields
%       'display'  - 3D display oriention, valid inputs are:
%              'sagittal', 'coronal','transverse'
%       'gridsize' - motion field display grid size in pixels
%       'motion" - 0, or 1, to display the motion field or not, default value is 0
%       'aspectratio" - display the images according to their voxel size ratio, or not, default is 1, mean 'yes'
%       'offsets' - the image offsets in pixels if image sizes are different
%       'window'  - display image intensity window width and level
%		'voxelsize' - set voxel sizes for both images
%
%reg3dgui M-file for reg3dgui.fig
%      reg3dgui, by itself, creates a new reg3dgui or raises the existing
%      singleton*.
%
%      H = reg3dgui returns the handle to a new reg3dgui or the handle to
%      the existing singleton*.
%
%      reg3dgui('Property','Value',...) creates a new reg3dgui using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to reg3dgui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      reg3dgui('CALLBACK') and reg3dgui('CALLBACK',hObject,...) call the
%      local function named CALLBACK in reg3dgui.M with the given input
%      arguments.
%
%      *See GUI Options_Show_Pixel_Information_Menu_Item on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reg3dgui

% Last Modified by GUIDE v2.5 07-Mar-2010 16:53:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reg3dgui_OpeningFcn, ...
                   'gui_OutputFcn',  @reg3dgui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

setinfotext('Busy');

vars = varargin;
if nargin > 0 && ~ischar(varargin{1})
	for k = 1:nargin
		names{k} = inputname(k);
	end
	vars{end+1} = names;
end

if nargout
    %[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	[varargout{1:nargout}] = gui_mainfcn(gui_State, vars{:});
else
    %gui_mainfcn(gui_State, varargin{:});
	gui_mainfcn(gui_State, vars{:});
end

% End initialization code - DO NOT EDIT

setinfotext('Ready');

return;


% --- Executes just before reg3dgui is made visible.
function reg3dgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for reg3dgui

handles.output = hObject;

%handles.current_display = [3 6 9 3 3 6 9 1];
handles.axes_handles = [handles.axes1a handles.axes1b handles.axes1c handles.axes1d ...
	handles.axes2a handles.axes2b handles.axes2c];
handles.sliderhandles = [handles.csno handles.ssno handles.tsno];
handles.sliderinputhandles = [handles.csinput handles.ssinput handles.tsinput];
handles.dvf_mode_menu_handles = [ handles.Hide_Motion_Menu_Item handles.OverallMotionMenuItem ...
	handles.Motion_Display_As_Grid_Menu_Item handles.MotionXMenuItem ...
	handles.MotionYMenuItem handles.MotionZMenuItem ...
	handles.MotionXYZMenuItem handles.Motion_Jacobian_Menu_Item handles.Display_Inverse_Consistency_Error_Menu_Item];
handles.dvf_selection_menu_handles = [ handles.Display_Backward_Motion_Menu_Item handles.Display_Forward_Motion_Menu_Item ...
	handles.MotionCurrentResMenuItem handles.MotionCurrentPassMenuItem ...
	handles.MotionCurrentIterationMenuItem];

handles.uipanel2_position = get(handles.uipanel2,'Position');
handles.uipanel1_position = get(handles.uipanel1,'Position');
handles.pausebutton_position = get(handles.pausebutton,'Position');
handles.abortbutton_position = get(handles.abortbutton,'Position');
gui_handles = handles;
handles2.gui_handles = gui_handles;
handles = handles2;

handles = InitUserData(handles);
handles = Logging(handles,'Initialization ...');

if ~isempty(varargin)
	handles = Logging(handles,'Starting with command line parameters');
	handles.images(1).image = single(varargin{1});
	handles.images(2).image = single(varargin{2});
	handles.images(1).class = class(handles.images(1).image);
	handles.images(2).class = class(handles.images(2).image);

	handles.images(1).filename = varargin{end}{1};
	handles.images(2).filename = varargin{end}{2};

	handles = Logging(handles,'\tUsing images passed in the command line: %s and %s',handles.images(1).filename,handles.images(2).filename);

	if iscell(varargin{end})
		inputnames = varargin{end};
		handles.images(1).filename = inputnames{1};
		handles.images(2).filename = inputnames{2};
	end

	handles.reg.images_setting.max_intensity_value = max([handles.images(1).image(:);handles.images(2).image(:)]);
	handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
	handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value;

	handles = reconfigure_sliders(handles);

	if length(varargin) > 2
		for k=3:length(varargin)-1
			varname = varargin{end}{k};
			if ischar(varargin{k})
				switch varargin{k}
					case 'i1vx'
						if ischar(varargin{k+1})
							setinfotext('Loading i1vx ...');
							load(varargin{k+1});
							handles = Logging(handles,'\ti1vx is loaded from file: %s', varargin{k+1});
							handles.images(1).image_deformed = i1vx;
							clear i1vx;
						else
							handles.images(1).image_deformed = varargin{k+1};
							handles = Logging(handles,'\ti1vx is passed from command line');
						end
					case 'i2vx'
						if ischar(varargin{k+1})
							setinfotext('Loading i2vx ...');
							load(varargin{k+1});
							handles.images(2).image_deformed = i2vx;
							clear i2vx;
							handles = Logging(handles,'\ti2vx is loaded from file: %s', varargin{k+1});
						else
							handles.images(2).image_deformed = varargin{k+1};
						end
						handles = Logging(handles,'\ti2vx is passed from command line');
					case 'mvs'
						if ischar(varargin{k+1})
							setinfotext('Loading mvs ...');
							load(varargin{k+1});
							handles.reg.dvf.x = mvx;
							handles.reg.dvf.y = mvy;
							handles.reg.dvf.z = mvz;
							clear mvx mvy mvz;
							handles = Logging(handles,'\tmvx,mvy,mvz are loaded from file: %s', varargin{k+1});
						else
							handles.reg.dvf.y = varargin{k+1}(:,:,:,1);
							handles.reg.dvf.x = varargin{k+1}(:,:,:,2);
							handles.reg.dvf.z = varargin{k+1}(:,:,:,3);
							handles = Logging(handles,'\tmvx,mvy,mvz are passed from command line');
						end
					case 'dvf'
						handles.reg.dvf = varargin{k+1};
						handles = Logging(handles,'\tDVF is passed from command line');
					case 'idvf'
						handles.reg.idvf = varargin{k+1};
						handles = Logging(handles,'\tIDVF is passed from command line');
					case {'mvx','dvfx','dvf.x'}
						handles.reg.dvf.x = varargin{k+1};
						handles = Logging(handles,'\tmvx is passed from command line');
					case {'mvy','dvfy','dvf.y'}
						handles.reg.dvf.y = varargin{k+1};
						handles = Logging(handles,'\tmvy is passed from command line');
					case {'mvz','dvfz','dvf.z'}
						handles.reg.dvf.z = varargin{k+1};
						handles = Logging(handles,'\tmvz is passed from command line');
					case 'display'
						if ischar(varargin{k+1})
							switch lower(varargin{k+1})
								case 'sagittal'
									handles.gui_options.display_mode(:,1)=1;
								case 'coronal'
									handles.gui_options.display_mode(:,1)=2;
								case 'transverse'
									handles.gui_options.display_mode(:,1)=3;
							end
						else
							handles.gui_options.display_mode = varargin{k+1};
						end
					case 'gridsize'
						handles.gui_options.motion_grid_size = varargin{k+1};
					case 'motion'
						set(handles.gui_handles.motioncheckbox,'Value',varargin{k+1});
					case 'aspectratio'
						set(handles.gui_handles.aspectratiocheckbox,'Value',varargin{k+1});
					case 'voxelsize'
						handles.images(1).voxelsize = varargin{k+1};
						handles.images(2).voxelsize = varargin{k+1};
					case 'offsets'
						handles.reg.images_setting.image_offsets = varargin{k+1};
						handles.reg.images_setting.image_current_offsets = varargin{k+1};
					case 'window'
						handles.gui_options.window_center = ones(1,7)*varargin{k+1}(1);
						handles.gui_options.window_width = ones(1,7)*varargin{k+1}(2);
					otherwise
						if( ischar(varargin{k}) )
							if isfield(handles,varargin{k})
								handles.(varargin{k}) = varargin{k+1};
								handles = Logging(handles,'\t%s is passed from command line',varargin{k});
							elseif isempty(handles.images(1).image_deformed) && ~isempty(findstr(varargin{k},'i1vx'))
								setinfotext('Loading i1vx ...');
								load(varargin{k});
								handles.images(1).image_deformed = i1vx;
								clear i1vx;
								handles = Logging(handles,'\ti1vx is loaded from %s', varargin{k});
							elseif isempty(handles.images(2).image_deformed) && ~isempty(findstr(varargin{k},'i2vx'))
								setinfotext('Loading i2vx ...');
								load(varargin{k});
								handles.images(2).image_deformed = i2vx;
								clear i2vx;
								handles = Logging(handles,'\ti2vx is loaded from %s', varargin{k});
							elseif isempty(handles.reg.dvf.x) && ~isempty(findstr(varargin{k},'mvs'))
								setinfotext('Loading mvs ...');
								load(varargin{k});
								handles.reg.dvf.x = mvx;
								handles.reg.dvf.y = mvy;
								handles.reg.dvf.z = mvz;
								clear mvx mvy mvz;
								handles = Logging(handles,'\tMotion fields are loaded from %s',varargin{k});
							end
						end
				end
				continue;
			else
				switch(varname)
					case 'i1vx'
						handles.images(1).image_deformed = varargin{k};
						handles = Logging(handles,'\ti1vx is passed from command line');
					case 'mvx'
						handles.reg.dvf.x = varargin{k};
						handles = Logging(handles,'\tmvx is passed from command line');
					case 'mvy'
						handles.reg.dvf.y = varargin{k};
						handles = Logging(handles,'\tmvy is passed from command line');
					case 'mvz'
						handles.reg.dvf.z = varargin{k};
						handles = Logging(handles,'\tmvz is passed from command line');
				end
				continue;
			end
		end
	end
end

if ~isempty(handles.images(1).image)
	handles = InitSliderPosition(handles);
	handles = reconfigure_sliders(handles);
end
handles = CheckSettingParameters(handles);

global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;

Save_Images_To_Temp_Folder(handles,0);
RefreshDisplay(handles);
handles.gui_options.lock_between_display = Check_MenuItem(handles.gui_handles.GUIOptions_Lock_Display_Menu_Item,0);
guidata(handles.gui_handles.figure1,handles);
set(handles.gui_handles.figure1,'Name',handles.info.name);

return;



% --- Outputs from this function are returned to the command line.
function varargout = reg3dgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.gui_handles.output;
if isunix 
% 	|| getMATLABversion > 7.3
	set(handles.gui_handles.Options_Show_Pixel_Information_Menu_Item,'checked','off');
else
	val = Check_MenuItem(handles.gui_handles.Options_Show_Pixel_Information_Menu_Item,0);
	if val == 1
		impixelinfo;
	end
end
Panel_Layout_2M_2S_Menu_Item_Callback(hObject, eventdata, handles);

if isempty(handles.images(1).image)
	FirstHelp;
end
return;

% --- Executes on button press in loadimage1button.
function Load_MATLAB_Images_Menu_Item_Callback(hObject, eventdata, handles)
Load_2_Images(handles,1);
return;

% --------------------------------------------------------------------
function Load_Images_From_CERR_Plans_Menu_Item_Callback(hObject, eventdata, handles)
Load_2_Images(handles,2);
return;

% --------------------------------------------------------------------
function Load_Dicom_Images_Menu_Item_Callback(hObject, eventdata, handles)
Load_2_Images(handles,3);
return;


% --------------------------------------------------------------------
function Load_Structure_Masks_Menu_Item_Callback(hObject, eventdata, handles)
setinfotext('Loading structure masks ...');
%handles.images(1).image = load_image;
[filename1, pathname1] = uigetfile({'*.mat'}, 'Select structure mask MATLAB file');
if filename1 == 0
	return;
end

mask = load_image_from_MATLAB_file([pathname1,filename1]);

if ~isequal(size(mask),size(handles.images(2).image))
	uiwait(warndlg('Structure mask is not good, its dimension is not the same as the image 1 dimension.'));
	return;
end

mask = uint32(mask);
handles.images(1).structure_mask = mask;

handles = Logging(handles,'structure masks are successfully loaded from %s', filename1);
guidata(handles.gui_handles.figure1, handles);
setinfotext('structure masks are successfully loaded');

return;

% --- Executes on button press in pausebutton.
function pausebutton_Callback(hObject, eventdata, handles)
% hObject    handle to pausebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Pause_Registration_Menu_Item_Callback(handles.gui_handles.Pause_Registration_Menu_Item, eventdata, handles);

% --- Executes on button press in abortbutton.
function abortbutton_Callback(hObject, eventdata, handles)
% hObject    handle to abortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Abort_Registration_Menu_Item_Callback(handles.gui_handles.Abort_Registration_Menu_Item, eventdata, handles);
return;



% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SkipDisplayUpdate();
for idx=1:7
	global skipdisplay;
	if (skipdisplay==1) break; end
	handles.gui_options.display_destination = 2;	% refresh the plots and save into files
	update_display(handles,idx);	
end

setinfotext(sprintf('Displayed images are saved'));

return;

% --- Executes on button press in savebutton.
function handle_sliders(hObject,handles,viewdir,force_update)
if ~exist('force_update','var')
	force_update = 0;
end
global skipdisplay;
SkipDisplayUpdate();
handles = guidata(handles.gui_handles.figure1);
newval = get(hObject,'Value');
newval = round(newval);
% curAxes = FindCurrentAxes(handles);
curAxes = handles.gui_options.current_axes_idx;
if curAxes<1 || (handles.gui_options.slidervalues(curAxes,viewdir) == newval && force_update == 0)
	return;
end
handles.gui_options.slidervalues(curAxes,viewdir) = newval;
set(handles.gui_handles.sliderinputhandles(viewdir),'String',num2str(newval));

if handles.gui_options.lock_between_display == 1
	handles = SetSlidersValueForOtherDisplays(handles,curAxes,viewdir);
	for k=1:7
		if handles.gui_options.display_mode(k,1) == viewdir
			% need to update this display
			if (skipdisplay==1)
				break;
			end
			update_display(handles,k);
		end
	end
else
	if handles.gui_options.display_mode(curAxes,1) == viewdir
		update_display(handles,curAxes);
	end
end
guidata(handles.gui_handles.figure1,handles);
return;



% --- Executes on slider movement.
function tsno_Callback(hObject, eventdata, handles)
% hObject    handle to tsno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handle_sliders(hObject,handles,3);
return;


% --- Executes during object creation, after setting all properties.
function tsno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;



% --- Executes on slider movement.
function csno_Callback(hObject, eventdata, handles)
% hObject    handle to csno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handle_sliders(hObject,handles,1);
return;


% --- Executes during object creation, after setting all properties.
function csno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to csno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;



% --- Executes on slider movement.
function ssno_Callback(hObject, eventdata, handles)
% hObject    handle to ssno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handle_sliders(hObject,handles,2);
return;


% --- Executes during object creation, after setting all properties.
function ssno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in colorcheckbox.
function handle_slider_input(hObject,handles,viewdir)

SkipDisplayUpdate();
newval = str2num(get(hObject,'String'));
newval = round(newval);
% curAxes = FindCurrentAxes(handles);
curAxes = handles.gui_options.current_axes_idx;
if curAxes<1 || newval == handles.gui_options.slidervalues(curAxes,viewdir)
	return;
end

handles.gui_options.slidervalues(curAxes,viewdir) = newval;
set(handles.gui_handles.sliderhandles(viewdir),'Value',newval);

global skipdisplay;
if handles.gui_options.lock_between_display == 1
	handles = SetSlidersValueForOtherDisplays(handles,curAxes,viewdir);
	for k=1:7
		if handles.gui_options.display_mode(k,1) == viewdir
			% need to update this display
			if (skipdisplay==1) 
				break; 
			end
			update_display(handles,k);
		end
	end
else
	if handles.gui_options.display_mode(curAxes,1) == viewdir
		update_display(handles,curAxes);
	end
end

guidata(handles.gui_handles.figure1,handles);
return;



function tsinput_Callback(hObject, eventdata, handles)
% hObject    handle to tsinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsinput as text
%        str2double(get(hObject,'String')) returns contents of tsinput as a double
handle_slider_input(hObject,handles,3);
return;

	
% --- Executes during object creation, after setting all properties.
function tsinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;




function csinput_Callback(hObject, eventdata, handles)
% hObject    handle to csinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of csinput as text
%        str2double(get(hObject,'String')) returns contents of csinput as a double
handle_slider_input(hObject,handles,1);
return;



% --- Executes during object creation, after setting all properties.
function csinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to csinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;




function ssinput_Callback(hObject, eventdata, handles)
% hObject    handle to ssinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ssinput as text
%        str2double(get(hObject,'String')) returns contents of ssinput as a double
handle_slider_input(hObject,handles,2);
return;



% --- Executes during object creation, after setting all properties.
function ssinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;



% --- Executes on button press in refreshbutton.
function Reflesh_Display_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to refreshbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RefreshDisplay(handles);
setinfotext('Views are refreshed');

return;


% --- Executes on selection change in regmethodpopupmenu.
function regmethodpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to regmethodpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns regmethodpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regmethodpopupmenu


% --- Executes during object creation, after setting all properties.
function regmethodpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regmethodpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in colorbarcheckbox.
function colorbarcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to colorbarcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colorbarcheckbox
ConditionalRefreshDisplay(handles,[6 7 10 14 15]);

return;


% --- Executes on button press in aspectratiocheckbox.
function aspectratiocheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to aspectratiocheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of aspectratiocheckbox


% --- Executes on button press in motioncheckbox.
function motioncheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to motioncheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of motioncheckbox
RefreshDisplay(handles);
return;


function motiongridsize_Callback(hObject, eventdata, handles)
% hObject    handle to motiongridsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motiongridsize as text
%        str2double(get(hObject,'String')) returns contents of motiongridsize as a double

if get(handles.gui_handles.motioncheckbox,'Value') == 1
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
end

return;


% --- Executes during object creation, after setting all properties.
function motiongridsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motiongridsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;




function zratioinput_Callback(hObject, eventdata, handles)
% hObject    handle to zratioinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zratioinput as text
%        str2double(get(hObject,'String')) returns contents of zratioinput as a double

% --- Executes during object creation, after setting all properties.
function zratioinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zratioinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in contourcheckbox.
function contourcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to contourcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of contourcheckbox

ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;


% --- Executes on button press in colorcheckbox.
function colorcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to colorcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colorcheckbox
if get(handles.gui_handles.motioncheckbox,'Value') == 1
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
else
	ConditionalRefreshDisplay(handles,6:9);
end
return;

% --- Executes on button press in allincolorcheckbox.
function allincolorcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to allincolorcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allincolorcheckbox
ConditionalRefreshDisplay(handles,1:5);
return;


% --- Executes on button press in standardsavepushbutton.
function standardsavepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to standardsavepushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SkipDisplayUpdate();

save_display_mode = handles.gui_options.display_mode;

a1=get(handles.gui_handles.allincolorcheckbox,'Value');
a2=get(handles.gui_handles.motioncheckbox,'Value');
a3=get(handles.gui_handles.aspectratiocheckbox,'Value');
a4=get(handles.gui_handles.colorbarcheckbox,'Value');
a5=get(handles.gui_handles.colorcheckbox,'Value');

set(handles.gui_handles.allincolorcheckbox,'Value',0);
set(handles.gui_handles.motioncheckbox,'Value',0);
set(handles.gui_handles.aspectratiocheckbox,'Value',1);
set(handles.gui_handles.colorbarcheckbox,'Value',1);
set(handles.gui_handles.colorcheckbox,'Value',1);

handles.gui_options.display_destination = 2;
handles.gui_options.display_mode(1,:) = [3 1];
update_display(handles,1);
saveas(11,'im1-unreg.png','png');
close(11);

handles.gui_options.display_mode(2,:) = [3 6];
update_display(handles,2);
saveas(12,'diff-unreg.png','png');
close(12);

handles.gui_options.display_mode(3,:) = [3 8];
update_display(handles,3);
saveas(13,'checker-unreg.png','png');
close(13);

handles.gui_options.display_mode(4,:) = [3 4];
update_display(handles,4);
saveas(14,'im1-reg.png','png');
close(14);

handles.gui_options.display_mode(5,:) = [3 2];
update_display(handles,5);
saveas(15,'im2.png','png');
close(15);

handles.gui_options.display_mode(6,:) = [3 7];
set(handles.gui_handles.axes2bpopupmenu,'Value',6);
update_display(handles,6);
saveas(16,'diff-reg.png','png');
close(16);

handles.gui_options.display_mode(7,:) = [3 9];
update_display(handles,7);
saveas(17,'checker-reg.png','png');
close(17);

setinfotext(sprintf('Standard images are saved'));

handles.gui_options.display_mode = save_display_mode;

set(handles.gui_handles.allincolorcheckbox,'Value',a1);
set(handles.gui_handles.motioncheckbox,'Value',a2);
set(handles.gui_handles.aspectratiocheckbox,'Value',a3);
set(handles.gui_handles.colorbarcheckbox,'Value',a4);
set(handles.gui_handles.colorcheckbox,'Value',a5);

return;

function checkerboard_size_input_Callback(hObject, eventdata, handles)
% hObject    handle to checkerboard_size_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of checkerboard_size_input as text
%        str2double(get(hObject,'String')) returns contents of checkerboard_size_input as a double
ConditionalRefreshDisplay(handles,8:9);
return;

% --- Executes during object creation, after setting all properties.
function checkerboard_size_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkerboard_size_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes on button press in checkerboard_grid_lines_checkbox.
function checkerboard_grid_lines_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to checkerboard_grid_lines_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkerboard_grid_lines_checkbox
ConditionalRefreshDisplay(handles,8:9);
return;


% --- Executes during object creation, after setting all properties.
function axes1apopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1apopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes1bpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1bpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;



% --- Executes during object creation, after setting all properties.
function axes1cpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1cpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes1dpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1dpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes2apopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2apopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes2bpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2bpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes2cpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2cpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% --- Executes during object creation, after setting all properties.
function axes2dpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2dpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;



% --- Executes on selection change in popupmenu_motion_selection.
function popupmenu_motion_selection_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_motion_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_motion_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_motion_selection
RefreshDisplay(handles);
return;


% --- Executes during object creation, after setting all properties.
function popupmenu_motion_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_motion_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;



% --------------------------------------------------------------------
function Export2FigureMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to Export2FigureMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SkipDisplayUpdate();
handles.gui_options.display_destination = 2;
for idx=1:7
	global skipdisplay;
	if (skipdisplay==1) break; end
	update_display(handles,idx);	% refresh the plots and save into files
end

return;


% --------------------------------------------------------------------
function Export2FigureMenuItem2_Callback(hObject, eventdata, handles)
% hObject    handle to Export2FigureMenuItem2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
standardsavepushbutton_Callback(hObject,eventdata,handles);
return;

% --------------------------------------------------------------------
function Registration_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Registration_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image)
	set(handles.gui_handles.Start_Registration_Menu_Item,'enable','on');
else
	set(handles.gui_handles.Start_Registration_Menu_Item,'enable','off');
end


% --------------------------------------------------------------------
function RegParMenu_Callback(hObject, eventdata, handles)
% hObject    handle to RegParMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DisplayOptionsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayOptionsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.images(1).image)
	set(handles.gui_handles.Mouse_Button_Actions_Menu,'enable','off');
else
	set(handles.gui_handles.Mouse_Button_Actions_Menu,'enable','on');
end
if isempty(handles.ART.dose)
	set(handles.gui_handles.Dose_Menu,'enable','off');
else
	set(handles.gui_handles.Dose_Menu,'enable','on');
end


% --------------------------------------------------------------------
function OptionsDisplayColorMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayColorMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_image_in_color',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,1:10);
return;


% --------------------------------------------------------------------
function OptionsDisplayCheckerboardImageInColorMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayCheckerboardImageInColorMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_checkerboard_in_color',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,8:9);
return;

% --------------------------------------------------------------------
function OptionsDisplayColorbarMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayColorbarMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_colorbar',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,[6 7 10 14:17]);
return;


% --------------------------------------------------------------------
function Display_Structure_In_Own_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Structure_In_Own_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'checked','on');
set(handles.gui_handles.Options_Display_Structure_Contours_1_Menu_Item,'checked','off');
set(handles.gui_handles.Options_Display_Structure_Contour_2_Menu_Item,'checked','off');

if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_contour_in_own_view(:) = 1;
	handles.gui_options.display_contour_1_in_all_views(:) = 0;
	handles.gui_options.display_contour_2_in_all_views(:) = 0;
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
else
	handles.gui_options.display_contour_in_own_view(handles.gui_options.current_axes_idx) = 1;
	handles.gui_options.display_contour_1_in_all_views(handles.gui_options.current_axes_idx) = 0;
	handles.gui_options.display_contour_2_in_all_views(handles.gui_options.current_axes_idx) = 0;
	update_display(handles,handles.gui_options.current_axes_idx);
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Options_Display_Structure_Contours_1_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Display_Structure_Contours_1_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = Check_MenuItem(hObject,1);
if val == 1
	set(handles.gui_handles.Display_Structure_In_Own_View_Menu_Item,'checked','off');
end

if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_contour_1_in_all_views(:) = val;
	if val == 1
		handles.gui_options.display_contour_in_own_view(:) = 0;
	end
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
else
	handles.gui_options.display_contour_1_in_all_views(handles.gui_options.current_axes_idx) = val;
	if val == 1
		handles.gui_options.display_contour_in_own_view(handles.gui_options.current_axes_idx) = 0;
	end
	update_display(handles,handles.gui_options.current_axes_idx);
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function OptionsDisplayMotionVectorMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayMotionVectorMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;

% --------------------------------------------------------------------
function OptionsDisplayGridLinesMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayGridLinesMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_checkerboard_gridlines',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,8:9);
return;

% --------------------------------------------------------------------
function OptionsDisplayCheckerboardSizeMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayCheckerboardSizeMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Y (mm)                          ','X (mm)','Z (mm)'};
name='Input for checkerboard grid size';
numlines=1;
idx = handles.gui_options.current_axes_idx;
defaultanswer={num2str(handles.gui_options.checkerboard_size(idx,1)),num2str(handles.gui_options.checkerboard_size(idx,2)),num2str(handles.gui_options.checkerboard_size(idx,3))};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	if handles.gui_options.lock_between_display == 1
		handles.gui_options.checkerboard_size(:,1) = str2double(answer{1});
		handles.gui_options.checkerboard_size(:,2) = str2double(answer{2});
		handles.gui_options.checkerboard_size(:,3) = str2double(answer{3});
		handles.gui_options.checkerboard_size = round(handles.gui_options.checkerboard_size);
		maxvals = ones(handles.gui_options.num_panels,3)*3;
		handles.gui_options.checkerboard_size = max(handles.gui_options.checkerboard_size,maxvals);
		guidata(handles.gui_handles.figure1,handles);
		ConditionalRefreshDisplay(handles,8:9);
	else
		idx = handles.gui_options.current_axes_idx;
		handles.gui_options.checkerboard_size(idx,1) = str2double(answer{1});
		handles.gui_options.checkerboard_size(idx,2) = str2double(answer{2});
		handles.gui_options.checkerboard_size(idx,3) = str2double(answer{3});
		handles.gui_options.checkerboard_size = round(handles.gui_options.checkerboard_size);
		maxvals = ones(handles.gui_options.num_panels,3)*3;
		handles.gui_options.checkerboard_size = max(handles.gui_options.checkerboard_size,maxvals);
		guidata(handles.gui_handles.figure1,handles);
		update_display(handles,idx);
	end
end

% --------------------------------------------------------------------
function OptionsDisplayKeepAspectRatioMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayKeepAspectRatioMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'keep_aspect_ratio',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;

% --------------------------------------------------------------------
function OptionsDisplayMotionGridSizeMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayMotionGridSizeMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = handles.gui_options.current_axes_idx;
prompt={'Vector Y spacing (mm)','Vector X spacing (mm)','Vector Z spacing (mm)','Line Width','Colorwash Transparency (0 to 1)'};
name='DVF display settings';
numlines=1;
defaultanswer={num2str(handles.gui_options.motion_grid_size(idx,1)),num2str(handles.gui_options.motion_grid_size(idx,2)),...
	num2str(handles.gui_options.motion_grid_size(idx,3)),num2str(handles.gui_options.motion_vector_line_width(idx)),...
	num2str(1-handles.gui_options.DVF_colorwash_alpha(idx),'%.1f')};
options.Resize='on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	if handles.gui_options.lock_between_display == 1
		idxes = 1:handles.gui_options.num_panels;
	else
		idxes = idx;
	end
	
	handles.gui_options.motion_grid_size(idxes,1) = max(str2double(answer{1}),2);
	handles.gui_options.motion_grid_size(idxes,2) = max(str2double(answer{2}),2);
	handles.gui_options.motion_grid_size(idxes,3) = max(str2double(answer{3}),2);
	handles.gui_options.motion_vector_line_width(idxes) = str2double(answer{4});
	handles.gui_options.DVF_colorwash_alpha(idxes) = 1-str2double(answer{5});
	guidata(handles.gui_handles.figure1,handles);
	
	if GetMotionDisplayModeSelection(handles) > 1
		if handles.gui_options.lock_between_display == 1
			RefreshDisplay(handles);
		else
			update_display(handles,idx);
		end
	end
end
return;

% --------------------------------------------------------------------
function Voxel_Size_Ratio_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Voxel_Size_Ratio_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ratio,voxelsize] = InputImageVoxelSizeRatio(handles.images(1).voxelsize);
if ~isempty(ratio)
	handles.images(1).voxelsize = voxelsize;
	handles.images(2).voxelsize = voxelsize;
	handles = Logging(handles,'Voxel size is updated to %s', num2str(handles.images(1).voxelsize,'%g  '));
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
	setinfotext('Image voxel size ratio is updated');
end
return;

% --------------------------------------------------------------------
function Image_Offset_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Voxel_Size_Ratio_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
name='Image offset in voxels';
image_offsets = User_Input_Offsets(name,handles.reg.images_setting.image_offsets);

if ~isempty(image_offsets)
	ChangeAlignment(handles,image_offsets);
end
return;


% --------------------------------------------------------------------
function OptionsDisplayMotionFieldMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsDisplayMotionFieldMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% childs = get(hObject,'child');
% if isempty(handles.reg.dvf.x)
% 	set(childs,'enable','off');
% else
% 	set(get(hObject,'child'),'enable','on');
% 	
% 	if isempty(handles.reg.idvf.x) || ~isequal(size(handles.reg.idvf.x),size(handles.images(2).image))
% 		set(handles.gui_handles.Overall_Motion_Forward_Menu_Item,'enable','off');
% 		set(handles.gui_handles.Overall_Motion_Grid_Forward_Menu_Item,'enable','off');
% 	else
% 		set(handles.gui_handles.Overall_Motion_Forward_Menu_Item,'enable','on');
% 		set(handles.gui_handles.Overall_Motion_Grid_Forward_Menu_Item,'enable','on');
% 	end
% 	
% 	set(handles.gui_handles.dvf_menu_handles,'checked','off');
% 	set(handles.gui_handles.dvf_menu_handles(handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx)+1),'checked','on');
% end
% return;


% --------------------------------------------------------------------
function OverallMotionMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OverallMotionMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,2,handles);
return;


% --------------------------------------------------------------------
function MotionCurrentResMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionCurrentResMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,3,handles);
return;


% --------------------------------------------------------------------
function MotionCurrentPassMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionCurrentPassMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,4,handles);
return;


% --------------------------------------------------------------------
function MotionCurrentIterationMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionCurrentIterationMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,5,handles);
return;


% --------------------------------------------------------------------
function Export_1_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%SkipDisplayUpdate();
handles.gui_options.display_destination = 2;
update_display(handles,eventdata);	% refresh the plots and save into files
return;

function Export_Plot_1_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,1);
return;


% --------------------------------------------------------------------
function Export_Plot_2_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,2);
return;

% --------------------------------------------------------------------
function Export_Plot_3_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,3);
return;


% --------------------------------------------------------------------
function Export_Plot_4_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,4);
return;


% --------------------------------------------------------------------
function Export_Plot_5_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,5);
return;


% --------------------------------------------------------------------
function Export_Plot_6_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,6);
return;


% --------------------------------------------------------------------
function Export_Plot_7_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Plot_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_destination = 2;
update_display(handles,7);
return;

% --------------------------------------------------------------------
function Export_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image)
	set(get(hObject,'child'),'enable','on');
else
	set(get(hObject,'child'),'enable','off');
end
return;

% --------------------------------------------------------------------
function Reflesh_Window_Level_Menu_Item_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Reflesh_Window_Level_Menu_Item_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RefreshDisplay(handles);
setinfotext('Views are refreshed');
return;

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close;
return;

% --------------------------------------------------------------------
function Image_Information_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);
str0 = sprintf('Image #1: %s\nImage #2: %s\n\n',handles.images(1).filename,handles.images(2).filename);
if isequal(dim2,dim1)
	str1 = sprintf('Image dimension: %d, %d, %d\n',dim1(1),dim1(2),dim1(3));
else
	str1 = sprintf('Image 1 dimension: %d, %d, %d\nImage 2 dimension: %d, %d, %d\n',dim1(1),dim1(2),dim1(3),dim2(1),dim2(2),dim2(3));
	str1 = [str1 sprintf('Image offsets: %d, %d, %d\n',handles.reg.images_setting.image_offsets(1),handles.reg.images_setting.image_offsets(2),handles.reg.images_setting.image_offsets(3))];
end

str2 = sprintf('Image voxel size: %g, %g, %g\n',handles.images(1).voxelsize(1),handles.images(1).voxelsize(2),handles.images(1).voxelsize(3));
uiwait(msgbox([str0 str1 str2],'Image Information'));

return;

% --------------------------------------------------------------------
function Popup_Menu_View_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_Menu_View_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;


% --------------------------------------------------------------------
function popupmenu_view_selection_menu_item_callback(hObject, newsel, handles)

return;

% --------------------------------------------------------------------
function popupmenu_view_selection_disable_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_popup_menu_view_selection_disable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

popupmenu_view_selection_menu_item_callback(hObject,1,handles);
return;

% --------------------------------------------------------------------
function popupmenu_view_selection_coronal_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,2,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_sagittal_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,3,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_transverse_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_transverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,4,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_coronal_difference_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_coronal_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,5,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_sagittal_difference_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_sagittal_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,6,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_transverse_difference_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_transverse_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,7,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_coronal_checkerboard_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_coronal_checkerboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,8,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_sagittal_checkerboard_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_sagittal_checkerboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,9,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_transverse_checkerboard_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_transverse_checkerboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,10,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_3D_isosurface_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_3D_isosurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,11,handles);
return;


% --------------------------------------------------------------------
function popupmenu_view_selection_image_information_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view_selection_image_information_menu_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu_view_selection_menu_item_callback(hObject,12,handles);
return;


% --------------------------------------------------------------------
function Load_I1VX_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_I1VX_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image)
	[mat,filename] = LoadMATFromfile('Loading deformed source image ...');
	if isempty(mat)
		setinfotext('Loading is cancelled');
		return;
	end
	
	if isfield(mat,'i1vx') && isequal(size(handles.images(2).image),size(mat.i1vx))
		handles.images(1).image_deformed = mat.i1vx;
		handles = Logging(handles,'i1vx is loaded from file: %s',filename);

		guidata(handles.gui_handles.figure1,handles);
		RefreshDisplay(handles);
		setinfotext('Deformed image #1 is loaded');
	else
		disp('Deformed result does not exist in the file, or the image size is different from current displayed image size');
		setinfotext('Deformed image #1 is not loaded');
	end
end
return;


% --------------------------------------------------------------------
function Load_MVS_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_MVS_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mat,filename] = LoadMATFromfile('Loading DVF ...');
if isempty(mat)
	setinfotext('Loading is cancelled');
	return;
end

if ~isfield(mat,'dvf')
	setinfotext('The file is not a saved motion field, stop!');
	return;
end

dvf = mat.dvf;

try
	if strcmpi(handles.images(2).UID,dvf.info.Fixed_Image_UID) == 1
		% This is for the fixed image
		handles.reg.dvf = dvf;
		setinfotext('This DVF is for the fixed image');
	elseif strcmpi(handles.images(2).UID,dvf.info.Moving_Image_UID) == 1
		% This is for the moving image
		handles.reg.idvf = dvf;
		setinfotext('This DVF is for the moving image');
	end
catch
	% Assume this is for the fixed image
	setinfotext('Warning: DVF does not match to the images');
	handles.reg.dvf = dvf;
end
handles = Logging(handles,'Motion field is loaded from file: %s',filename);
guidata(handles.gui_handles.figure1,handles);
if GetMotionDisplaySelection(handles) > 1
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
end
setinfotext('Deformable fields are loaded');
return;


% --------------------------------------------------------------------
function Save_Results_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Results_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image)
	set(get(hObject,'child'),'enable','on');
% 	set(handles.gui_handles.Save_Images_Menu_Item,'enable','on');
else
	set(get(hObject,'child'),'enable','off');
	set(handles.gui_handles.Export_Data_To_MATLAB_Menu_Item,'enable','on');
% 	set(handles.gui_handles.Save_Images_Menu_Item,'enable','off');
	return;
end

if ~isempty(handles.images(1).image_deformed)
	set(handles.gui_handles.Save_I1VX_Menu_Item,'enable','on');
else
	set(handles.gui_handles.Save_I1VX_Menu_Item,'enable','off');
end
if ~isempty(handles.reg.dvf.x)
	set(handles.gui_handles.Save_MVS_Menu_Item,'enable','on');
else
	set(handles.gui_handles.Save_MVS_Menu_Item,'enable','off');
end
return;



% --------------------------------------------------------------------
function Save_I1VX_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_I1VX_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image_deformed)
% 	i1vx = cast(handles.images(1).image_deformed * handles.reg.images_setting.max_intensity_value, handles.images(1).class);
	i1vx = cast(handles.images(1).image_deformed, handles.images(1).class);
	SaveMAT2file('Saving deformed source image to MATLAB file',i1vx);
	setinfotext('Deformed image #1 is saved');
end
return;


% --------------------------------------------------------------------
function Save_MVS_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_MVS_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.reg.dvf.x)
	if ~isfield(handles.reg.dvf,'info') || isempty(handles.reg.dvf.info)
		handles = FillDVFInfo(handles,1);
	end
	dvf = handles.reg.dvf;
	filename = SaveMAT2file('Saving deformation fields to MATLAB file',dvf);
	if filename ~= 0
		setinfotext(sprintf('Deformation fields are saved to: %s', filename));
	end
end
return;

% --------------------------------------------------------------------
function Pause_Registration_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Pause_Registration_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = Check_MenuItem(hObject,1);
return;

% --------------------------------------------------------------------
function Load_Results_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Results_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.images(1).image)
	menus = get(hObject,'child');
	set(menus,'Enable','on');
else
	menus = get(hObject,'child');
	set(menus,'Enable','off');
end
return;

% --------------------------------------------------------------------
function handles = Clear_Results_On_Handles(handles)
handles = RemoveUndoInfo(handles);
if ~isempty(handles.images(1).image)
	handles = Clear_Results(handles);
end
return;

% --------------------------------------------------------------------
function Clear_Results_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Results_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = Load_Images_From_Temp_Folder(handles,0);
handles2 = Clear_Results_On_Handles(handles);
if ~isequalwithequalnans(handles2,handles)
	handles = handles2; clear handles2;
	handles = Logging(handles,'Registration results are cleared at %s', datestr(now));
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
	setinfotext('Images have been reset and all resutls are cleared');
	set(handles.gui_handles.figure1,'Name',handles.info.name);
end

return;


% --------------------------------------------------------------------
function ProcessMotionSelectionMenu(hObject,idx,handles)
% current_sel = GetMotionDisplaySelection(handles);
current_sel = handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,1);
menus = get(handles.gui_handles.Motion_Field_Selection_Menu,'child');
set(menus,'Checked','off');
set(hObject,'Checked','on');
if idx ~= current_sel
	if handles.gui_options.lock_between_display == 1
		handles.gui_options.DVF_displays(:,1) = idx;
		guidata(handles.gui_handles.figure1,handles);
		ConditionalRefreshDisplay(handles,[1:9 19 20]);
	else
		handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,1)=idx;
		guidata(handles.gui_handles.figure1,handles);
		update_display(handles,handles.gui_options.current_axes_idx);
	end
end

return;

% --------------------------------------------------------------------
function ProcessMotionModeSelectionMenu(hObject,idx,handles)
% current_sel = GetMotionDisplayModeSelection(handles);
current_sel = handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,2);
menus = get(handles.gui_handles.Motion_Display_Mode_Menu,'child');
set(menus,'Checked','off');
set(hObject,'Checked','on');
if idx ~= current_sel
	if handles.gui_options.lock_between_display == 1
		handles.gui_options.DVF_displays(:,2) = idx;
		guidata(handles.gui_handles.figure1,handles);
		ConditionalRefreshDisplay(handles,[1:9 19 20]);
	else
		handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,2)=idx;
		guidata(handles.gui_handles.figure1,handles);
		update_display(handles,handles.gui_options.current_axes_idx);
	end
end

return;

% --------------------------------------------------------------------
function Hide_Motion_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Hide_Motion_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,1,handles);
return;

% --------------------------------------------------------------------
function Overall_Motion_Forward_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Overall_Motion_Forward_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,6,handles);
return;


% --------------------------------------------------------------------
function Motion_Display_As_Grid_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Motion_Display_As_Grid_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,3,handles);
return;


% --------------------------------------------------------------------
function Overall_Motion_Grid_Backward_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Overall_Motion_Grid_Backward_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,8,handles);
return;


% --------------------------------------------------------------------
function Registration_Algorithms_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Registration_Algorithms_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if ~isempty(handles.images(1).image)
% 	set(get(hObject,'child'),'enable','on');
% else
% 	set(get(hObject,'child'),'enable','off');
% end

% --------------------------------------------------------------------
function Abort_Registration_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Abort_Registration_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = Check_MenuItem(hObject,1);
if value == 1
	set(hObject,'Label','Aborting - In Progress, please wait ...');
	set(handles.gui_handles.abortbutton,'String','Aborting ...','enable','off');
	set(hObject,'Enable','off');
end
%setinfotext('Registration process is aborted');

return;

% --------------------------------------------------------------------
function Stop_Current_Stage_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_Current_Stage_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

value = Check_MenuItem(hObject,1);
if value == 1
	set(hObject,'Label','Stopping curren stage - In Progress, please wait ...');
	set(hObject,'Enable','off');
end


% --------------------------------------------------------------------
function Optical_Flow_Method_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Optical_Flow_Method_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Level_Set_Motion_Method_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Level_Set_Motion_Method_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ITK_Demon_Method_Menu_Item_Start_Registration_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item_Start_Registration_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Other_Iterative_Start_Registration_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Other_Iterative_Start_Registration_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function HS_Optical_Flow_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Optical_Flow_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,1,handles);
return;

% --------------------------------------------------------------------
function LKT_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to LKT_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,11,handles);
return;

% --------------------------------------------------------------------
function LKT_Method_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to LKT_Method_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,2,handles);
return;

% --------------------------------------------------------------------
function Combined_HS_LK_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Combined_HS_LK_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,6,handles);
return;

% --------------------------------------------------------------------
function LSM_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to LSM_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,28,handles);
return;


% --------------------------------------------------------------------
function LSM_Method_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to LSM_Method_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,9,handles);
return;


% --------------------------------------------------------------------
function HS_Issam_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Issam_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,8,handles);
return;

% --------------------------------------------------------------------
function HS_Divergence_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Divergence_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,12,handles);
return;

% --------------------------------------------------------------------
function HSC_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HSC_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,13,handles);
return;


% --------------------------------------------------------------------
function HSC_Divergence_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HSC_Divergence_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,14,handles);
return;


% --------------------------------------------------------------------
function HS_Reverse_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Reverse_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,15,handles);
return;


% --------------------------------------------------------------------
function HSC_reverse_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HSC_reverse_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,16,handles);
return;


% --------------------------------------------------------------------
function LSM_Affine_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to LSM_Affine_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,10,handles);
return;


% --------------------------------------------------------------------
function Iterative_OF_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Iterative_OF_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,20,handles);
return;


% --------------------------------------------------------------------
function Iterative_OF_Fast_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Iterative_OF_Fast_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,23,handles);
return;


% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Iterative_LSM_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Iterative_LSM_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,21,handles);
return;


% --------------------------------------------------------------------
function SSD_Minimization_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to SSD_Minimization_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,19,handles);
return;


% --------------------------------------------------------------------
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.images(1).image)
	set(handles.gui_handles.Clear_Results_Menu_Item,'enable','on');
	set(handles.gui_handles.Reflesh_Display_Menu_Item,'enable','on');
	set(handles.gui_handles.Image_Information_Menu_Item,'enable','on');
	set(handles.gui_handles.File_Image_Alignment_Menu,'enable','on');
	set(handles.gui_handles.Save_Entire_Data_Set_Menu_Item,'enable','on');
	set(handles.gui_handles.Save_Results_Menu,'enable','on');
	set(handles.gui_handles.Load_Results_Menu,'enable','on');
else
	set(handles.gui_handles.Clear_Results_Menu_Item,'enable','off');
	set(handles.gui_handles.Reflesh_Display_Menu_Item,'enable','off');
	set(handles.gui_handles.Image_Information_Menu_Item,'enable','off');
	set(handles.gui_handles.File_Image_Alignment_Menu,'enable','off');
	set(handles.gui_handles.Save_Entire_Data_Set_Menu_Item,'enable','off');
	set(handles.gui_handles.Save_Results_Menu,'enable','off');
	set(handles.gui_handles.Load_Results_Menu,'enable','off');
end

return;


% --------------------------------------------------------------------
function Save_MVS_mm_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_MVS_mm_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Save_MVS_Binary_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_MVS_Binary_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Preprocessing_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Preprocessing_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.images(1).image)
	set(get(hObject,'child'),'enable','on');
	if isequal(size(handles.images(1).image),size(handles.images(2).image))
		set(handles.gui_handles.Crop_Larger_Image_Menu_Item,'enable','off');
% 	else
% 		set(handles.gui_handles.Crop_Larger_Image_Menu_Item,'enable','on');
	end
	if ~isfield(handles,'undo_handles')
% 		set(handles.gui_handles.Preprocessing_Undo_Menu_Item,'enable','on');
% 	else
		set(handles.gui_handles.Preprocessing_Undo_Menu_Item,'enable','off');
	end
else
	set(get(hObject,'child'),'enable','off');
end
return;

% --------------------------------------------------------------------
function Smoothing_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'smooth');
return;
% --------------------------------------------------------------------
function Smoothing_2_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'edge_preserve_smooth');
return;
% --------------------------------------------------------------------
function HE_method_1_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images_2(handles,'histogram_equalization');
return;


% --------------------------------------------------------------------
function Window_Level_Transform_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Transform_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Preprocessing_Images(handles,'Window_Level_Transform');

return;


% --------------------------------------------------------------------
function CLAHE_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images_2(handles,'CLAHE');
return;


% --------------------------------------------------------------------
function Intensity_Correction_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images_2(handles,'Intensity_Correction');
return;

% --------------------------------------------------------------------
function About_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to About_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AboutDIRART;
return;



% --------------------------------------------------------------------
function Help_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Help_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Stages_Selection_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Stages_Selection_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(get(handles.gui_handles.Stages_Selection_Menu,'child'),'Checked','off');
switch handles.reg.Multigrid_Stages
	case 1
		set(handles.gui_handles.Stage_1_Menu_Item,'Checked','on');
	case 2
		set(handles.gui_handles.Stage_2_Menu_Item,'Checked','on');
	case 3
		set(handles.gui_handles.Stage_3_Menu_Item,'Checked','on');
	case 4
		set(handles.gui_handles.Stage_4_Menu_Item,'Checked','on');
	case 5
		set(handles.gui_handles.Stage_5_Menu_Item,'Checked','on');
end

return;

function Process_Multigrid_Stage_Selection(hObject,num,handles)
set(get(handles.gui_handles.Stages_Selection_Menu,'child'),'Checked','off');
set(hObject,'Checked','on');
handles.reg.Multigrid_Stages = num;
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Stage_1_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stage_1_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Process_Multigrid_Stage_Selection(hObject,1,handles);
return;


% --------------------------------------------------------------------
function Stage_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stage_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Process_Multigrid_Stage_Selection(hObject,2,handles);
return;


% --------------------------------------------------------------------
function Stage_3_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stage_3_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Process_Multigrid_Stage_Selection(hObject,3,handles);
return;


% --------------------------------------------------------------------
function Stage_4_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stage_4_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Process_Multigrid_Stage_Selection(hObject,4,handles);
return;


% --------------------------------------------------------------------
function Stage_5_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Stage_5_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Process_Multigrid_Stage_Selection(hObject,5,handles);
return;


% --------------------------------------------------------------------
function Iteration_Parameters_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Iteration_Parameters_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hdl = openfig('iteration_parameters.fig');
set(findobj(hdl,'Tag','ni1'),'string',num2str(handles.reg.maxiters(1)));
set(findobj(hdl,'Tag','ni2'),'string',num2str(handles.reg.maxiters(2)));
set(findobj(hdl,'Tag','ni3'),'string',num2str(handles.reg.maxiters(3)));
set(findobj(hdl,'Tag','ni4'),'string',num2str(handles.reg.maxiters(4)));
set(findobj(hdl,'Tag','ni5'),'string',num2str(handles.reg.maxiters(5)));

set(findobj(hdl,'Tag','np1'),'string',num2str(handles.reg.passes_in_stages(1)));
set(findobj(hdl,'Tag','np2'),'string',num2str(handles.reg.passes_in_stages(2)));
set(findobj(hdl,'Tag','np3'),'string',num2str(handles.reg.passes_in_stages(3)));
set(findobj(hdl,'Tag','np4'),'string',num2str(handles.reg.passes_in_stages(4)));
set(findobj(hdl,'Tag','np5'),'string',num2str(handles.reg.passes_in_stages(5)));

set(findobj(hdl,'Tag','nstages'),'string',num2str(handles.reg.Multigrid_Stages));
set(findobj(hdl,'Tag','stop1'),'string',num2str(handles.reg.minimal_max_motion_per_iteration));
set(findobj(hdl,'Tag','stop2'),'string',num2str(handles.reg.minimal_max_motion_per_pass));
set(findobj(hdl,'Tag','smoothing1'),'string',num2str(handles.reg.smoothing_in_iteration));
set(findobj(hdl,'Tag','smoothing2'),'string',num2str(handles.reg.smoothing_after_pass,'%g '));
set(findobj(hdl,'Tag','multigrid_filter_type'),'value',handles.reg.multigrid_filter_type);

uiwait;

if ishandle(hdl)
	handles.reg.maxiters(1) = str2num(get(findobj(hdl,'Tag','ni1'),'string'));
	handles.reg.maxiters(2) = str2num(get(findobj(hdl,'Tag','ni2'),'string'));
	handles.reg.maxiters(3) = str2num(get(findobj(hdl,'Tag','ni3'),'string'));
	handles.reg.maxiters(4) = str2num(get(findobj(hdl,'Tag','ni4'),'string'));
	handles.reg.maxiters(5) = str2num(get(findobj(hdl,'Tag','ni5'),'string'));

	handles.reg.passes_in_stages(1) = str2num(get(findobj(hdl,'Tag','np1'),'string'));
	handles.reg.passes_in_stages(2) = str2num(get(findobj(hdl,'Tag','np2'),'string'));
	handles.reg.passes_in_stages(3) = str2num(get(findobj(hdl,'Tag','np3'),'string'));
	handles.reg.passes_in_stages(4) = str2num(get(findobj(hdl,'Tag','np4'),'string'));
	handles.reg.passes_in_stages(5) = str2num(get(findobj(hdl,'Tag','np5'),'string'));

	handles.reg.Multigrid_Stages = str2num(get(findobj(hdl,'Tag','nstages'),'string'));
	handles.reg.minimal_max_motion_per_iteration = str2num(get(findobj(hdl,'Tag','stop1'),'string'));
	handles.reg.minimal_max_motion_per_pass = str2num(get(findobj(hdl,'Tag','stop2'),'string'));
	handles.reg.smoothing_in_iteration = str2num(get(findobj(hdl,'Tag','smoothing1'),'string'));
	handles.reg.smoothing_after_pass = str2num(get(findobj(hdl,'Tag','smoothing2'),'string'));
	handles.reg.multigrid_filter_type = get(findobj(hdl,'Tag','multigrid_filter_type'),'value');
	
	close(hdl);
	
	handles = Logging(handles,['Registration parameters are changed to:\n'...
		'\t\tmaxiters = [%s]\n' ...
		'\t\tpasses_in_stages = [%s]\n' ...
		'\t\tMultigrid_Stages = [%d]\n' ...
		'\t\tminimal_max_motion_per_iteration = [%s]\n' ...
		'\t\tminimal_max_motion_per_pass = [%s]\n' ...
		'\t\tsmoothing_in_iteration = [%s]\n' ... 
		'\t\tsmoothing_after_pass = [%s]\n' ...
		'\t\tmultigrid_filter_type = [%d]' ], ...
		num2str(handles.reg.maxiters,'%g  '), num2str(handles.reg.passes_in_stages,'%g  '), ...
		handles.reg.Multigrid_Stages, num2str(handles.reg.minimal_max_motion_per_iteration,'%g  '), ...
		num2str(handles.reg.minimal_max_motion_per_pass,'%g  '), ...
		num2str(handles.reg.smoothing_in_iteration,'%g  '), ...
		num2str(handles.reg.smoothing_after_pass,'%g  '), ...
		handles.reg.multigrid_filter_type);
	
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('Registration iteration parameters have been updated');
else
	setinfotext('Registration iteration parameters are not updated');
end

return;

% --------------------------------------------------------------------
function GPRduce_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images_2(handles,'GPReduce');
return;

% --------------------------------------------------------------------
function Save_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[path1,filename1] = fileparts(handles.images(1).filename);
if ~isempty(handles.images(1).image)
	%filename = SaveMAT2file2(sprintf('Saving image #1: %s',filename1),handles.images(1).image*handles.reg.images_setting.max_intensity_value);
	filename = SaveMAT2file2(sprintf('Saving image #1: %s',filename1),handles.images(1).image);
	if filename ~= 0 
		setinfotext(sprintf('Image 1 have been saved into %s',filename));
		[path2,filename2] = fileparts(handles.images(2).filename);
% 		filename2 = SaveMAT2file2(sprintf('Saving image #2: %s',filename2),handles.images(2).image*handles.reg.images_setting.max_intensity_value);
		filename2 = SaveMAT2file2(sprintf('Saving image #2: %s',filename2),handles.images(2).image);
		if filename2 ~= 0
			setinfotext(sprintf('Images 2 have been saved into %s',filename2));
		else
			setinfotext('Image #2 have not been saved');
		end
	else
		setinfotext('Images have not been saved');
	end
end
return;

% --------------------------------------------------------------------
function Crop_Image_Menu_Item_Callback(hObject, eventdata, handles)
% Crop_Image_CallBack(handles,1);
Crop_Image_3D(handles,1);
return;

% --------------------------------------------------------------------
function Crop_Image_2_Menu_Item_Callback(hObject, eventdata, handles)
Crop_Image_Callback(handles,2);
return;


% --------------------------------------------------------------------
function Crop_Larger_Image_Menu_Item_Callback(hObject, eventdata, handles)
Crop_Larger_Image_Callback(handles);
return;


% --------------------------------------------------------------------
function Padding_Image_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'padding');
return;

% --------------------------------------------------------------------
function Normalized_Image_Size_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'normalize');
return;

% --------------------------------------------------------------------
function Flip_AP_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'flip_ap');
return;

% --------------------------------------------------------------------
function Flip_LR_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'flip_lr');
return;

% --------------------------------------------------------------------
function Flip_SI_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'flip_si');
return;

% --------------------------------------------------------------------
function View_Mode_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to View_Mode_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Coronal_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Coronal_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_mode(:,1) = 1;
	handles = SetSlidersValueForOtherDisplays(handles);
	RefreshDisplay(handles);
	setinfotext('All views are changed to coronal mode');
else
	idx = handles.gui_options.current_axes_idx;
	handles.gui_options.display_mode(idx,1) = 1;
	update_display(handles,idx)
	setinfotext('Changed to coronal mode');
end
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Sagittal_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Sagittal_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_mode(:,1) = 2;
	handles = SetSlidersValueForOtherDisplays(handles);
	RefreshDisplay(handles);
	setinfotext('All views are changed to sagittal mode');
else
	idx = handles.gui_options.current_axes_idx;
	handles.gui_options.display_mode(idx,1) = 2;
	update_display(handles,idx)
	setinfotext('Changed to sagittal mode');
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Transverse_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Transverse_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_mode(:,1) = 3;
	handles = SetSlidersValueForOtherDisplays(handles);
	RefreshDisplay(handles);
	setinfotext('All views are changed to transverse mode');
else
	idx = handles.gui_options.current_axes_idx;
	handles.gui_options.display_mode(idx,1) = 3;
	update_display(handles,idx)
	setinfotext('Changed to transverse mode');
end
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Disable_Views_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Disable_Views_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_enabled(:) = 1-handles.gui_options.display_enabled(:);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
setinfotext('All views are disabled');
return;



% --------------------------------------------------------------------
function Postprocessing_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Postprocessing_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(get(hObject,'child'),'enable','off');
if ~isempty(handles.reg.dvf.x)
	if isfield(handles.reg,'landmark_data') && isequal(mysize(handles.images(1).image),handles.reg.landmark_data.dim1) ...
			&& isequal(mysize(handles.images(2).image),handles.reg.landmark_data.dim2) && isfield(handles,'mvx')
		set(handles.gui_handles.Accuracy_Analysis_Menu_Item,'enable','on');
		set(handles.gui_handles.Compute_Moved_Land_Marks_Menu_Item,'enable','on');
	end
	set(handles.gui_handles.Deform_Moving_Menu_Item,'enable','on');
	set(handles.gui_handles.Compute_Inverse_DVF_Menu_Item,'enable','on');
	set(handles.gui_handles.Ground_Truth_Analysis_Menu_Item,'enable','on');
	set(handles.gui_handles.Load_Land_Marks_Menu_Item,'enable','on');
end

if ~isempty(handles.reg.idvf.x)
	set(handles.gui_handles.Deform_Fixed_Image_Menu_Item,'enable','on');
	set(handles.gui_handles.Compute_DVF_From_Inverse_DVF_Menu_Item,'enable','on');
end

if ~isempty(handles.reg.idvf.x) && ~isempty(handles.reg.dvf.x)
	set(handles.gui_handles.Inverse_Consistency_Analysis_Menu_Item,'enable','on');
end

if ~isempty(handles.reg.idvf.x) || ~isempty(handles.reg.dvf.x)
	set(handles.gui_handles.Smooth_Motion_Field_Menu_Item,'enable','on');
	set(handles.gui_handles.Jacobian_Analysis_Menu_Item,'enable','on');
	set(handles.gui_handles.Remove_DVF_Menu_Item,'enable','on');
end

if ~isempty(handles.images(1).image) && ~isempty(handles.images(1).image_deformed)
	set(handles.gui_handles.Similarity_Measurement_Menu_Item,'enable','on');
end

return;

% --------------------------------------------------------------------
function Deform_Moving_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Deform_Moving_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter = 'linear';
Deform_Moving_Image(handles,filter);
return;

% --------------------------------------------------------------------
function ITK_Demon_Method_Menu_Item_Methods_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item_Methods_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Other_Iterative_Methods_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Other_Iterative_Methods_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in abortbutton.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to abortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Export_2_Workspace_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Export_2_Workspace_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Image #1','Image #2','Deformed Image #1',...
	'Motion vector in AP direction','Motion vector in LR direction','Motion vector in SI direction'};
name='To export results to MATLAB workspace, please enter variable names to use';
numlines=1;
defaultanswer={'img1','img2','i1vx','mvy','mvx','mvz'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	image1varname = answer{1};
	image2varname = answer{2};
	i1vxvarname = answer{3};
	mvyvarname = answer{4};
	mvxvarname = answer{5};
	mvzvarname = answer{6};
	
	try
		if isfield(handles,'images') && ~isempty(image1varname)
			assignin('base',image1varname,handles.images(1).image);
		end

		if isfield(handles,'images') && ~isempty(image2varname)
			assignin('base',image2varname,handles.images(2).image);
		end

		if ~isempty(handles.images(1).image_deformed) && ~isempty(i1vxvarname)
			assignin('base',i1vxvarname,handles.images(1).image_deformed);
		end

		if ~isempty(handles.reg.dvf.x)
			if ~isempty(mvyvarname)
				assignin('base',mvyvarname,handles.reg.dvf.y);
			end
			
			if ~isempty(mvxvarname)
				assignin('base',mvxvarname,handles.reg.dvf.x);
			end

			if ~isempty(mvzvarname)
				assignin('base',mvzvarname,handles.reg.dvf.z);
			end
		end
	end
	setinfotext('Results are exported to MATLAB workspace');
end
return;


% --------------------------------------------------------------------
function Export_Data_To_MATLAB_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Data_To_MATLAB_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'GUI Data variable name, ? to list all variables'};
name='To export GUI data to MATLAB workspace, please enter data variable names';
numlines=1;
defaultanswer={'?'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	varname = answer{1};
	if varname(1) == '?'
		% list variable names
		fnames = fieldnames(handles);
		N = 1;
		for k = 1:length(fnames)
			fprintf('%d\t%s\n',N,fnames{k});
			N = N+1;
		end
	else
		if isfield(handles,varname)
			assignin('base',varname,handles.(varname));
			setinfotext(sprintf('GUI data "%s" is exported to MATLAB workspace',varname));
		else
			setinfotext(sprintf('GUI data "%s" does not exist',varname));
		end
	end
end
return;

% --------------------------------------------------------------------
function Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Window Center','Window Width'};
name='Set window level';
numlines=1;
defaultanswer={num2str(handles.gui_options.window_center(1)),num2str(handles.gui_options.window_width(1))};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
if ~isempty(answer)
	window_center = str2num(answer{1});
	%window_center = min(window_center,1); window_center = max(window_center,0);
	window_width = str2num(answer{2});
	%window_width = max(window_width,0.1); window_width = min(window_width,2);
	
	if window_center ~= handles.gui_options.window_center(1) || window_width ~= handles.gui_options.window_width(1)
		handles.gui_options.window_width = ones(1,7)*window_width;
		handles.gui_options.window_center = ones(1,7)*window_center;
		reg3dgui_global_windows_centers = handles.gui_options.window_center;
		reg3dgui_global_windows_widths = handles.gui_options.window_width;
		handles = Logging(handles,'Window level is changed to width = %d, center = %d', window_width, window_center);
		guidata(handles.gui_handles.figure1,handles);
		ConditionalRefreshDisplay(handles,[1:9 19 20]);
	end
end
return;

% --------------------------------------------------------------------
function pmenu_export_to_figure_menu_item_Callback(hObject, eventdata, handles)
% hObject    handle to pmenu_export_to_figure_menu_item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = FindCurrentAxes(handles);
if idx < 1 || handles.gui_options.display_enabled(idx) == 0
	return;
end

handles.gui_options.display_destination = 2;
update_display(handles,idx);
return;


% --------------------------------------------------------------------
function Auto_Align_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Align_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

[dy dx dz] = translation_only_align_CT(handles.images(1).image,handles.images(2).image);

if ~isequal(handles.reg.images_setting.image_offsets,[dy dx dz])
	handles.reg.images_setting.image_offsets = [dy dx dz];
	handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
	handles = Logging(handles,'Automatic align images to offsets = [%s]',num2str([dy dx dz]));
	
	guidata(handles.gui_handles.figure1,handles);
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
end
return;

% --------------------------------------------------------------------
function KVCT_2_MVCT_Intensity_Remap_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'kv_2_mv_remap');
return;

% --------------------------------------------------------------------
function Bowel_Gas_Pocket_Impaint_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'bowel_gas_painting');
return;

% --------------------------------------------------------------------
function Apply_2_Image_1_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_2_Image_1_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
% guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Apply_2_Image_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_2_Image_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
% guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Save_Entire_Data_Set_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Entire_Data_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = RemoveUndoInfo(handles);
handles = rmfield(handles,'gui_handles');
filename = SaveMAT2file('Saving Entire Data Set to MATLAB file',handles);

if filename ~= 0
	setinfotext(sprintf('Entire Data Set is saved to %s',filename));
else
	setinfotext('Entire Data Set is not saved');
end

return;

% --------------------------------------------------------------------
function Load_Entire_Data_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Entire_Data_Set_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mat,filename] = LoadMATFromfile('Loading Entire Data Set from MATLAB file');
if isempty(mat)
	setinfotext('Loading is cancelled');
	return;
end

handles = Clear_Results_On_Handles(handles);
handles = InitUserData(handles);
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;

if isfield(mat,'handles') && isfield(mat.handles,'gui_options')
	handles = Load_Entire_Data_Menu_Item_New(handles,mat);
	handles = Logging(handles,'Project is loaded from "%s"', filename);
	guidata(handles.gui_handles.figure1,handles);
else
	handles.physical_origins{1} = [0 0 0];
	handles.physical_origins{2} = [0 0 0];
	handles.voxel_spacing_dirs{1} = [1 1 1];
	handles.voxel_spacing_dirs{2} = [1 1 1];
	handles.image_filenames{1} = '';
	handles.image_filenames{2} = '';
	handles.original_voxelsizes{1} = [1 1 1];
	handles.original_voxelsizes{2} = [1 1 1];
	handles.voxelsizes{1} = [1 1 1];
	handles.voxelsizes{2} = [1 1 1];
	handles.i1vx = [];
	handles.i2vx = [];
	handles.mvx = [];
	handles.mvy = [];
	handles.mvz = [];
	handles.imvx = [];
	handles.imvy = [];
	handles.imvz = [];
	handles.image_types{1} = 'CT';
	handles.image_types{2} = 'CT';
	handles.structure_masks{1} = [];
	handles.structure_masks{2} = [];
	handles.structure_names{1} = [];
	handles.structure_names{2} = [];
	handles.images = [];
	handles.image_classes{1} = 'single';
	handles.image_classes{2} = 'single';

	if isfield(mat,'img1')
		% this is the old save files

		handles.mvx = mat.mvx;
		handles.mvy = mat.mvy;
		handles.mvz = mat.mvz;
		handles.i1vx = mat.i1vx;
		handles.images{1} = mat.img1;
		handles.images{2} = mat.img2;

		if isfield(mat,'processed_images_1')
			handles.images{1} = mat.processed_images_1;
			handles.images{2} = mat.processed_images_2;
		end

		handles.image_filenames{1} = filename;
		handles.image_filenames{2} = filename;

		if ~isfield(mat,'voxelsizes')
			handles.voxelsizes{1} = mat.voxelsize;
			handles.voxelsizes{2} = mat.voxelsize;
		else
			handles.voxelsizes = mat.voxelsizes;
		end
		handles.image_offsets = mat.image_offsets;
		handles.image_current_offsets = mat.image_current_offsets;

		if isfield(mat,'image_filenames_1')
			handles.image_filenames{1} = mat.image_filenames_1;
			handles.image_filenames{2} = mat.image_filenames_2;
		end

		if isfield(mat,'max_intensity_value')
			handles.reg.images_setting.max_intensity_value = mat.max_intensity_value;
		else
			handles.reg.images_setting.max_intensity_value = max(max(handles.images(1).image(:)),max(handles.images(2).image(:)));
		end
		handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
		handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value;
		reg3dgui_global_windows_centers = handles.gui_options.window_center;
		reg3dgui_global_windows_widths = handles.gui_options.window_width;

		handles.reg = rmfield_from_struct(handles.reg,{'jacobian','landmark_data','inverse_consistency_errors'});

		if isfield(mat,'imvx')
			handles.imvx = mat.imvx;
			handles.imvy = mat.imvy;
			handles.imvz = mat.imvz;
		end

		if isfield(mat,'i2vx')
			handles.i2vx = mat.i2vx;
		else
			handles.i2vx = [];
		end
	else
		handles2 = mat.handles;

		names = fieldnames(handles2);
		for k = 1:length(names)
			handles.(names{k}) = handles2.(names{k});
		end
	end

	if isfield(handles,'voxelsize_1')
		handles.original_voxelsizes{1} = handles.voxelsize_1;
		handles.original_voxelsizes{2} = handles.voxelsize_2;
		handles = rmfield(handles,{'voxelsize_1','voxelsize_2'});
	end

	if ~isfield(handles,'voxelsizes')
		handles.voxelsizes{1} = handles.voxelsize;
		handles.voxelsizes{2} = handles.voxelsize;
	end

	if isfield(handles,'structure_masks_2')
		structure_masks{1} = handles.structure_masks;
		structure_masks{2} = handles.structure_masks_2;
		handles = rmfield(handles,'structure_masks_2');
		handles.structure_masks = structure_masks;
		clear structure_masks;
	end

	if isfield(handles,'structure_names_2')
		structure_names{1} = handles.structure_names;
		structure_names{2} = handles.structure_names_2;
		handles = rmfield(handles,'structure_names_2');
		handles.structure_names = structure_names;
		clear structure_names;
	end

	if isfield(handles,'processed_images')
		handles.images = handles.processed_images;
		handles = rmfield(handles,'processed_images');
	end

	if isfield(handles,'original_images')
		handles = rmfield(handles,'original_images');
	end

	if isfield(handles,'original_voxelsizes')
		handles = rmfield(handles,'original_voxelsizes');
	end

	if isfield(handles,'original_structure_masks')
		handles = rmfield(handles,'original_structure_masks');
	end

	if isfield(handles,'original_structure_masks_2')
		handles = rmfield(handles,'original_structure_masks_2');
	end

	handles = Convert_Old_Project(handles);
	handles = After_Loading_Saved_Project(handles);
	handles = Logging(handles,'Project (old versions) is loaded from "%s" and converted.', filename);
	guidata(handles.gui_handles.figure1,handles);
end
return;


% --------------------------------------------------------------------
function handles = Load_Entire_Data_Menu_Item_New(handles,mat)
handles = CopyDataStructures(mat.handles,handles);
handles = After_Loading_Saved_Project(handles);
return;

% --------------------------------------------------------------------
function Nonlinear_Histogram_Adjustment_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'Nonlinear_Histogram_Adjustment');
return;


% --------------------------------------------------------------------
function handles = Compute_Inverse_DVF_Menu_Item_Callback(hObject, eventdata, handles,expand)
% hObject    handle to Compute_Inverse_DVF_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setinfotext('Busy, inverting the motion field ...');
% drawnow;
handles_new = InvertDVF(handles,1);
if ~isequalwithequalnans(handles_new,handles)
	handles = handles_new;
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('Inverting the motion field finished.');
	drawnow;
end
return;


% --------------------------------------------------------------------
function Save_Temp_Results_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Temp_Results_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reg.Save_Temp_Results = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);

return;


% --------------------------------------------------------------------
function ITK_Methods_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Methods_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ndims(handles.images(1).image) == 3
	if exist('BSplineMI.dll') == 3
		set(handles.gui_handles.B_Spline_Method_Menu_Item,'enable','on');
	else
		set(handles.gui_handles.B_Spline_Method_Menu_Item,'enable','off');
	end

	if exist('levelsetMethod3D.dll') == 3
		set(handles.gui_handles.ITK_Level_Set_Method_Menu_Item,'enable','on');
	else
		set(handles.gui_handles.ITK_Level_Set_Method_Menu_Item,'enable','off');
	end

	if exist('SymmetricDemons3D.dll') == 3
		set(handles.gui_handles.ITK_Symmetric_Demon_Method_Menu_Item,'enable','on');
	else
		set(handles.gui_handles.ITK_Symmetric_Demon_Method_Menu_Item,'enable','off');
	end

	if exist('Demons3D.dll') == 3
		set(handles.gui_handles.ITK_Demon_Method_Menu_Item,'enable','on');
	else
		set(handles.gui_handles.ITK_Demon_Method_Menu_Item,'enable','off');
	end
else
	set(handles.gui_handles.ITK_Symmetric_Demon_Method_Menu_Item,'enable','on');
	set(handles.gui_handles.ITK_Level_Set_Method_Menu_Item,'enable','off');
	set(handles.gui_handles.B_Spline_Method_Menu_Item,'enable','off');
	if exist('Demon') == 3
		set(handles.gui_handles.ITK_Demon_Method_Menu_Item,'enable','on');
	else
		set(handles.gui_handles.ITK_Demon_Method_Menu_Item,'enable','off');
	end
end

return;


% --------------------------------------------------------------------
function ITK_Demon_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Select_Registration_Algorithm(hObject,25,handles);
return;

% --------------------------------------------------------------------
function B_Spline_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to B_Spline_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,29,handles);
return;

% --------------------------------------------------------------------
function Demon_Methods_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Demon_Methods_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return;


% --------------------------------------------------------------------
function ITK_Symmetric_Demon_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Symmetric_Demon_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,26,handles);
return;


% --------------------------------------------------------------------
function ITK_Level_Set_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Level_Set_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,27,handles);
return;

% --------------------------------------------------------------------
function Demon_Method_4_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Demon_Method_4_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,24,handles);
return;


function Demon_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,17,handles);
return;

% --------------------------------------------------------------------
function Demon_Method_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item_Method_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,18,handles);
return;


% --------------------------------------------------------------------
function Demon_Method_3_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Demon_Method_Menu_Item_Method_3_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,22,handles);
return;


% --------------------------------------------------------------------
function Number_Of_Loops_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Number_Of_Loops_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:5
	prompt{i} = sprintf('Number of passess for stage %d',i);
	def{i} = num2str(handles.reg.passes_in_stages(i));
end
dlg_title = 'Input numbers of passes for each image resolution stage';
num_lines = 1;
options.Resize='on';
answer = inputdlg(prompt,dlg_title,num_lines,def,options);

if ~isempty(answer)
	for i = 1:5
		newvals(i) = round(str2num(answer{i}));
	end
	newvals = max(newvals,1);
	newvals = min(newvals,10);
	if ~isequal(newvals,handles.reg.passes_in_stages)
		handles.reg.passes_in_stages = newvals;
		guidata(handles.gui_handles.figure1,handles);
	end
end

return;


% --------------------------------------------------------------------
function HS_Optical_Flow_Method_Integer_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Optical_Flow_Method_Integer_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,3,handles);
return;


% --------------------------------------------------------------------
function HS_Optical_Flow_Method_Memory_Saving_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HS_Optical_Flow_Method_Memory_Saving_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,4,handles);
return;


% --------------------------------------------------------------------
function Free_Form_Deformation_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Free_Form_Deformation_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,30,handles);
return;


% --------------------------------------------------------------------
function Load_Land_Marks_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Land_Marks_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setinfotext('Loading land mark data ...');
[filename, pathname] = uigetfile({'*.mat'}, 'Select a MATLAB file');
if filename == 0
	setinfotext('Cancelled');
	return;
end

landmark_data = load([pathname filename]);
if ~isequal(mysize(handles.images(1).image),landmark_data.dim1) || ~isequal(mysize(handles.images(2).image),landmark_data.dim2)
	setinfotext('FAILED: Image dimension does not match');
	return;
end

handles.reg.landmark_data = landmark_data;
handles = Logging(handles,'Landmark data is loaded from %s', [filename, pathname]);
guidata(handles.gui_handles.figure1,handles);

return;


% --------------------------------------------------------------------
function Compute_Moved_Land_Marks_Menu_Item_Callback(hObject, eventdata, handles)
Compute_Moved_Land_Marks_Callback(handles);
return;

% --------------------------------------------------------------------
function Accuracy_Analysis_Menu_Item_Callback(hObject, eventdata, handles)
Accuracy_Analysis_Callback(handles);
return;

% --------------------------------------------------------------------
function Inverse_Consistency_Analysis_Menu_Item_Callback(hObject, eventdata, handles)
Reverse_Consistency_Analysis_Callback(handles);
return;


% --------------------------------------------------------------------
function Jacobian_Analysis_Menu_Item_Callback(hObject, eventdata, handles)
Jacobian_Analysis_Callback(handles);
return;

% --------------------------------------------------------------------
function Popup_Menu_View_Selection_2_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_Menu_View_Selection_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = FindCurrentAxes(handles);
if idx < 1
	return;
end

if ~isfield(handles,'images') || isempty(handles.images(1).image)
	set(get(hObject,'child'),'enable','off');
	return;
else
	set(get(hObject,'child'),'enable','on');
end

view_menu = handles.gui_handles.Popup2_View_Menu;
if ndims(handles.images(1).image) == 3
	current_view = handles.gui_options.display_mode(idx,1);
	set(get(view_menu,'child'),'checked','off');
	switch(current_view)
		case 1	% Coronal view
			set(handles.gui_handles.Popup2_Coronal_Menu_Item,'checked','on');
		case 2	% Sagittal view
			set(handles.gui_handles.Popup2_Sagittal_Menu_Item,'checked','on');
		otherwise % Transverse view
			set(handles.gui_handles.Popup2_Transverse_Menu_Item,'checked','on');
	end
else
	set(view_menu,'enable','off');
end

show_menu = handles.gui_handles.Popup2_Show_Menu_Item;
set(get(show_menu,'child'),'checked','off');
set(handles.gui_handles.Popup2_Disable_Menu_Item,'checked','off');
set(get(show_menu,'child'),'enable','on');
current_show = handles.gui_options.display_mode(idx,2);
if handles.gui_options.display_enabled(idx) == 0
	set(handles.gui_handles.Popup2_Disable_Menu_Item,'checked','on');
end

switch current_show
	case 1	% Image 1
		set(handles.gui_handles.Popup2_Image_1_Menu_Item,'checked','on');
	case 2	% Image 2
		set(handles.gui_handles.Popup2_Image_2_Menu_Item,'checked','on');
	case 3	% Combined image
		set(handles.gui_handles.Popup2_Combined_Image_Menu_Item,'checked','on');
	case 4	% Deformed image 1
		set(handles.gui_handles.Popup2_I1VX_Menu_Item,'checked','on');
	case 5	% Deformed image 2
		set(handles.gui_handles.Popup2_I2VX_Menu_Item,'checked','on');
	case 6	% Difference image before registration
		set(handles.gui_handles.Popup2_Difference_Before_Image_Menu_Item,'checked','on');
	case 7	% Difference image after registration
		set(handles.gui_handles.Popup2_Difference_After_Image_Menu_Item,'checked','on');
	case 8	% Checkerboard image before
		set(handles.gui_handles.Popup2_Checkerboard_Before_Menu_Item,'checked','on');
	case 9	% Checkerboard image after
		set(handles.gui_handles.Popup2_Checkerboard_After_Menu_Item,'checked','on');
	case 10	% Jacobian
		set(handles.gui_handles.Popup2_Jacobian_Menu_Item,'checked','on');
	case 11	% Information before registration
		set(handles.gui_handles.Popup2_Information_Before_Menu_Item,'checked','on');
	case 12	% Information after registration
		set(handles.gui_handles.Popup2_Information_After_Menu_Item,'checked','on');
	case 13	% 3D view
		set(handles.gui_handles.Popup2_3D_View_Menu_Item,'checked','on');
	case 14	% Motion field X
		set(handles.gui_handles.Popup2_Motion_Field_X_Menu_Item,'checked','on');
	case 15	% Motion field Y
		set(handles.gui_handles.Popup2_Motion_Field_Y_Menu_Item,'checked','on');
	case 16	% Motion field Z
		set(handles.gui_handles.Popup2_Motion_Field_Z_Menu_Item,'checked','on');
	case 17	% Motion field abs
		set(handles.gui_handles.Popup2_Absolute_Motion_Magnitude_Menu_Item,'checked','on');
	case 18	% Motion field color coded
		set(handles.gui_handles.Popup2_Color_Coded_Motion_Field_Menu_Item,'checked','on');
	case 19 % Difference before in colormap
		set(handles.gui_handles.Popup2_Colormaped_Difference_Before_Image_Menu_Item,'checked','on');
	case 20 % Difference after in colormap
		set(handles.gui_handles.Popup2_Colormaped_Difference_After_Image_Menu_Item,'checked','on');
	otherwise	% Difference image
		set(handles.gui_handles.Popup2_Difference_Image_Menu_Item,'checked','on');
end

if isempty(handles.images(2).image_deformed)
	set(handles.gui_handles.Popup2_I2VX_Menu_Item,'enable','off');
end

return;


% --------------------------------------------------------------------
function Popup2_Disable_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Disable_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 0, handles);
return;


% --------------------------------------------------------------------
function Popup2_View_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_View_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Popup2_Image_1_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Image_1_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 1, handles);
return;

% --------------------------------------------------------------------
function Popup2_Show_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Show_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Popup2_Image_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Image_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 2, handles);
return;


% --------------------------------------------------------------------
function Popup2_Difference_Before_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Difference_Before_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 6, handles);
return;


% --------------------------------------------------------------------
function Popup2_I1VX_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_I1VX_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 4, handles);
return;


% --------------------------------------------------------------------
function Popup2_I2VX_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_I2VX_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 5, handles);
return;


% --------------------------------------------------------------------
function Popup2_Checkerboard_Before_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Checkerboard_Before_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 8, handles);
return;


% --------------------------------------------------------------------
function Popup2_Coronal_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Coronal_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_view_selection_menu_item_callback(hObject, 1, handles);
return;

% --------------------------------------------------------------------
function Popup2_Sagittal_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Sagittal_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_view_selection_menu_item_callback(hObject, 2, handles);
return;


% --------------------------------------------------------------------
function Popup2_Transverse_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Transverse_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_view_selection_menu_item_callback(hObject, 3, handles);
return;


% --------------------------------------------------------------------
function Popup2_Combined_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Combined_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 3, handles);
return;


% --------------------------------------------------------------------
function Popup2_Jacobian_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Jacobian_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 10, handles);
return;


% --------------------------------------------------------------------
function Popup2_Difference_After_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Difference_After_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 7, handles);
return;


% --------------------------------------------------------------------
function Popup2_Checkerboard_After_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Checkerboard_After_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 9, handles);
return;


% --------------------------------------------------------------------
function Popup2_Information_Before_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Information_Before_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 11, handles);
return;


% --------------------------------------------------------------------
function Popup2_Information_After_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Information_After_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 12, handles);
return;


% --------------------------------------------------------------------
function popupmenu2_show_selection_menu_item_callback(hObject, newsel, handles)

idx = FindCurrentAxes(handles);
if idx < 1
	return;
end
SkipDisplayUpdate();

if newsel == 0
	handles.gui_options.display_enabled(idx) = 1-handles.gui_options.display_enabled(idx);
	update_display(handles,idx);
	guidata(handles.gui_handles.figure1,handles);
else
	if handles.gui_options.display_mode(idx,2) ~= newsel || handles.gui_options.display_enabled(idx) == 0
		handles.gui_options.display_enabled(idx) = 1;
		handles.gui_options.display_mode(idx,2) = newsel;
		
		% Set the slider according to the image size
		handles = SetSliders(handles,idx);
		update_display(handles,idx);
		guidata(handles.gui_handles.figure1,handles);
	end
end
return;

% --------------------------------------------------------------------
function popupmenu2_view_selection_menu_item_callback(hObject, newsel, handles)

SkipDisplayUpdate();
idx = FindCurrentAxes(handles);
if idx < 1
	return;
end

if handles.gui_options.display_mode(idx,1) ~= newsel
	handles.gui_options.display_mode(idx,1) = newsel;
	update_display(handles,idx);
	guidata(handles.gui_handles.figure1,handles);
end
return;


% --------------------------------------------------------------------
function Popup2_3D_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_3D_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 13, handles);
return;


% --------------------------------------------------------------------
function Popup2_Export_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Export_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = FindCurrentAxes(handles);
if idx < 1
	return;
end

if handles.gui_options.display_enabled(idx) ~= 0
	handles.gui_options.display_destination = 2;
	update_display(handles,idx);
end
return;


% --------------------------------------------------------------------
function Option_Show_Land_Marks_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Show_Land_Marks_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_landmarks',Check_MenuItem(hObject,1));
% 
% Check_MenuItem(hObject,1);
% if isfield(handles.reg,'landmark_data')
% 	ConditionalRefreshDisplay(handles,[1:9 19 20]);
% end
return;


% --------------------------------------------------------------------
function Option_Panel_Layout_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Panel_Layout_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Panel_Layout_7Sl_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_7Sl_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xpos = [0.008 0.255 0.502 0.749];

for k = 1:4
	set(handles.gui_handles.axes_handles(k),'visible','on');
	set(handles.gui_handles.axes_handles(k),'Position',[xpos(k) 0.51 0.24 0.47]);
end

for k = 5:7
	set(handles.gui_handles.axes_handles(k),'visible','on');
	set(handles.gui_handles.axes_handles(k),'Position',[xpos(k-4) 0.019 0.24 0.47]);
end

set(handles.gui_handles.uipanel2,'Position',handles.gui_handles.uipanel2_position);
set(handles.gui_handles.uipanel1,'Position',handles.gui_handles.uipanel1_position);
set(handles.gui_handles.pausebutton,'Position',handles.gui_handles.pausebutton_position);
set(handles.gui_handles.abortbutton,'Position',handles.gui_handles.abortbutton_position);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
return;

% --------------------------------------------------------------------
function Panel_Layout_1L_3S_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_1L_3S_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xpos = [0.008 0.255 0.502 0.749];

for k = 1:4
	set(handles.gui_handles.axes_handles(k),'visible','on');
end
set(handles.gui_handles.axes_handles(1),'Position',[xpos(1) 0.019 0.24*2.04 0.47*2.04]);
set(handles.gui_handles.axes_handles(2),'Position',[xpos(3) 0.51 0.24 0.47]);
set(handles.gui_handles.axes_handles(3),'Position',[xpos(4) 0.51 0.24 0.47]);
set(handles.gui_handles.axes_handles(4),'Position',[xpos(3) 0.019 0.24 0.47]);

for k = 5:7
	delete(get(handles.gui_handles.axes_handles(k),'child'));
	set(handles.gui_handles.axes_handles(k),'visible','off');
end

set(handles.gui_handles.uipanel2,'Position',handles.gui_handles.uipanel2_position);
set(handles.gui_handles.uipanel1,'Position',handles.gui_handles.uipanel1_position);
set(handles.gui_handles.pausebutton,'Position',handles.gui_handles.pausebutton_position);
set(handles.gui_handles.abortbutton,'Position',handles.gui_handles.abortbutton_position);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
return;


% --------------------------------------------------------------------
function Panel_Layout_3M_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_3M_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Panel_Layout_2M_2S_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_2M_2S_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xpos = [0.008 0.255 0.502 0.749];
width = 0.24*1.5;
height = 0.47*1.5;

for k = 1:4
	set(handles.gui_handles.axes_handles(k),'visible','on');
end

set(handles.gui_handles.axes_handles(1),'Position',[xpos(1) 0.273 width height]);
set(handles.gui_handles.axes_handles(2),'Position',[0.38    0.273 width height]);
set(handles.gui_handles.axes_handles(3),'Position',[xpos(4) 0.51 0.24 0.47]);
set(handles.gui_handles.axes_handles(4),'Position',[xpos(4) 0.019 0.24 0.47]);

for k = 5:7
	delete(get(handles.gui_handles.axes_handles(k),'child'));
	set(handles.gui_handles.axes_handles(k),'visible','off');
end

pos2 = handles.gui_handles.uipanel2_position;
pos2(1) = 0.008;
pos2(2) = 0.08;
set(handles.gui_handles.uipanel2,'Position',pos2);
set(handles.gui_handles.uipanel1,'Position',[0.26 0.019 0.36 0.23]);
set(handles.gui_handles.pausebutton,'Position',[0.635 0.16 0.1 0.05]);
set(handles.gui_handles.abortbutton,'Position',[0.635 0.1 0.1 0.05]);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
return;


% --------------------------------------------------------------------
function Panel_Layout_1L_1S_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_1L_1S_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xpos = [0.008 0.255 0.502 0.749];

for k = 1:2
	set(handles.gui_handles.axes_handles(k),'visible','on');
end
set(handles.gui_handles.axes_handles(1),'Position',[xpos(1) 0.019 0.24*3.06 0.47*2.04]);
set(handles.gui_handles.axes_handles(2),'Position',[xpos(4) 0.51 0.24 0.47]);

for k = 3:7
	delete(get(handles.gui_handles.axes_handles(k),'child'));
	set(handles.gui_handles.axes_handles(k),'visible','off');
end

set(handles.gui_handles.uipanel2,'Position',handles.gui_handles.uipanel2_position);
set(handles.gui_handles.uipanel1,'Position',handles.gui_handles.uipanel1_position);
set(handles.gui_handles.pausebutton,'Position',handles.gui_handles.pausebutton_position);
set(handles.gui_handles.abortbutton,'Position',handles.gui_handles.abortbutton_position);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
return;

% --------------------------------------------------------------------
function Panel_Layout_2L_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Panel_Layout_2L_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xpos = [0.008 0.504];

for k = 1:2
	set(handles.gui_handles.axes_handles(k),'visible','on');
end
set(handles.gui_handles.axes_handles(1),'Position',[xpos(1) 0.273 0.48 0.7]);
set(handles.gui_handles.axes_handles(2),'Position',[xpos(2) 0.273 0.48 0.7]);

for k = 3:7
	delete(get(handles.gui_handles.axes_handles(k),'child'));
	set(handles.gui_handles.axes_handles(k),'visible','off');
end

pos2 = handles.gui_handles.uipanel2_position;
pos2(1) = 0.008;
pos2(2) = 0.08;
set(handles.gui_handles.uipanel2,'Position',pos2);
set(handles.gui_handles.uipanel1,'Position',[0.26 0.019 0.36 0.23]);
set(handles.gui_handles.pausebutton,'Position',[0.635 0.16 0.1 0.05]);
set(handles.gui_handles.abortbutton,'Position',[0.635 0.1 0.1 0.05]);

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
return;


% --------------------------------------------------------------------
function Reverse_Registration_Direction_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Reverse_Registration_Direction_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

Reset_Registration_Results_Menu_Item_Callback(hObject, eventdata, handles);

temp = handles.images(2);
handles.images(2) = handles.images(1);
handles.images(1) = temp;

if isfield(handles,'cropped_image_offsets_in_original')
	handles.reg.images_setting.cropped_image_offsets_in_original = flipud(handles.reg.images_setting.cropped_image_offsets_in_original);
end

tempdvf = handles.reg.dvf;
handles.reg.dvf = handles.reg.idvf;
handles.reg.idvf = tempdvf;

handles.reg.images_setting.image_current_offsets = -handles.reg.images_setting.image_current_offsets;
handles.reg.images_setting.image_offsets = -handles.reg.images_setting.image_offsets;
handles.reg.images_setting.images_alignment_points = handles.reg.images_setting.images_alignment_points([2 1],:);
if ~isequal(size(handles.images(1).image),size(handles.images(2).image))
	handles = reconfigure_sliders(handles);	
end

if ~isempty(handles.ART.dose)
	N = length(handles.ART.dose);
	for k = 1:N
		handles.ART.dose{k}.association = 3-handles.ART.dose{k}.association;
	end
end

if ~isempty(handles.ART.structures)
	handles.ART.structure_assocImgIdxes = 3 - handles.ART.structure_assocImgIdxes;
end

handles = set_display_geometry_limits(handles);
setinfotext('Registration direction is reversed.');
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

return;


% --------------------------------------------------------------------
function Similarity_Measurement_Menu_Item_Callback(hObject, eventdata, handles)
Similarity_Measurement_Callback(handles);
return


% --------------------------------------------------------------------
function Ground_Truth_Analysis_Menu_Item_Callback(hObject, eventdata, handles)
Ground_Truth_Analysis_Callback(handles);
return;

% --------------------------------------------------------------------
function Popup2_Motion_Field_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Motion_Field_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Popup2_Motion_Field_X_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Motion_Field_X_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 14, handles);
return;


% --------------------------------------------------------------------
function Popup2_Motion_Field_Y_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Motion_Field_Y_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 15, handles);
return;


% --------------------------------------------------------------------
function Popup2_Motion_Field_Z_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Motion_Field_Z_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 16, handles);
return;


% --------------------------------------------------------------------
function Popup2_Absolute_Motion_Magnitude_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Absolute_Motion_Magnitude_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 17, handles);
return;


% --------------------------------------------------------------------
function Popup2_Color_Coded_Motion_Field_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Color_Coded_Motion_Field_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 18, handles);
return;


% --------------------------------------------------------------------
function Options_Show_Pixel_Information_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_Pixel_Information_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = Check_MenuItem(hObject,1);
if val == 1
	hpixelinfo = findobj(handles.gui_handles.figure1,'tag','pixelinfo panel');
	if isempty(hpixelinfo)
		impixelinfo;
	end
else
	hpixelinfo = findobj(handles.gui_handles.figure1,'tag','pixelinfo panel');
	if ~isempty(hpixelinfo)
		delete(hpixelinfo);
	end
end
RefreshDisplay(handles);
return;

% --------------------------------------------------------------------
function Load_2D_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_2D_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = RemoveUndoInfo(handles);
handles = rmfield(handles,'images');

current_dir = pwd;

setinfotext('Loading image #1');
%handles.images(1).image = load_image;
[filename1, pathname1] = uigetfile({'*.*'}, 'Select image # 1');	% Load a 3D image in MATLAB *.mat file
if filename1 == 0
	return;
end

setinfotext('Loading image #2');
%handles.images(2).image = load_image;
cd(pathname1);
[filename2, pathname2] = uigetfile({'*.*'}, 'Select image # 2');	% Load a 3D image in MATLAB *.mat file
cd(current_dir);
if filename2 == 0
	return;
end

img1 = imread([pathname1 filename1]);
handles.images(1).class = class(img1);
img1 = single(img1);
img1 = max(img1,0);
setinfotext('Image #1 is loaded');
handles = Logging(handles,'Loading 2D image #1 from %s', [pathname1 filename1]);

img2 = imread([pathname2 filename2]);
handles.images(2).class = class(img2);
img2 = single(img2);
img2 = max(img2,0);
setinfotext('Image #2 is loaded');
handles = Logging(handles,'Loading 2D image #1 from %s', [pathname2 filename2]);


if ~isequal(size(img1),size(img2))
	uiwait(warndlg('Image dimensions are not equal'));
end

maxv1 = max(img1(:));
maxv = max(maxv1,max(img2(:)));

handles.images(1).filename = filename1;
% handles.images(1).image = img1 / maxv;
handles.images(2).filename = filename2;
% handles.images(2).image = img2 / maxv;
handles.reg.images_setting.max_intensity_value = maxv;
handles.gui_options.window_center = ones(1,7)*handles.reg.images_setting.max_intensity_value/2;
handles.gui_options.window_width = ones(1,7)*handles.reg.images_setting.max_intensity_value;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;

% guidata(handles.gui_handles.figure1, handles);

handles.images(1).image = img1;
handles.images(2).image = img2;

setinfotext('Both images are successfully loaded'); drawnow;

handles.images(1).voxelsize = [1 1 1];
handles.images(2).voxelsize = [1 1 1];
handles.reg.images_setting.image_offsets = [0 0 0];
handles.reg.images_setting.image_current_offsets = [0 0 0];

handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);

% Save_Images_To_Temp_Folder(handles,0);

Clear_Results_Menu_Item_Callback(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function Symmetric_Force_Demons_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Symmetric_Force_Demons_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,31,handles);
return;


% --------------------------------------------------------------------
function Double_Force_Demons_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Double_Force_Demons_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Select_Registration_Algorithm(hObject,32,handles);
return;


% --------------------------------------------------------------------
function Enable_Log_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Enable_Log_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reg.Log_Output = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Registration_Options_Callback(hObject, eventdata, handles)
% hObject    handle to Registration_Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.reg.dvf.x) && isequal(size(handles.reg.dvf.x),size(handles.images(2).image))
	set(handles.gui_handles.Use_Current_Results_and_Continue_Menu_Item,'enable','on');
else
	set(handles.gui_handles.Use_Current_Results_and_Continue_Menu_Item,'enable','off');
end

% --------------------------------------------------------------------
function Generate_Reverse_Motion_Field_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Generate_Reverse_Motion_Field_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.reg.Generate_Reverse_Consistent_Motion_Field = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Save_IMVS_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_IMVS_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.reg.idvf.x)
	dvf = handles.reg.idvf;
	filename = SaveMAT2file('Saving reverse deformation fields to MATLAB file',dvf);
	if filename ~= 0
		setinfotext(sprintf('Reverse deformation fields are saved to: %s', filename));
	end
end
return;


% --------------------------------------------------------------------
function Remove_DVF_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_DVF_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dvfno = which_DVF_to_process(handles,'Which DVF to delete ?','Deleting DVF');
if dvfno == 0
	return;
end

if dvfno == 2 && ~isempty(handles.reg.idvf.x)
	handles.reg.idvf.x = [];
	handles.reg.idvf.y = [];
	handles.reg.idvf.z = [];
	handles.reg.idvf.info = [];
	handles = Logging(handles,'Inverse DVF is removed');
	
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('Inverse DVF is removed.');
elseif dvfno == 1 && ~isempty(handles.reg.dvf.x)
	handles.reg.dvf.x = [];
	handles.reg.dvf.y = [];
	handles.reg.dvf.z = [];
	handles.reg.dvf.info = [];
	handles = Logging(handles,'DVF is removed');
	
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('DVF is removed.');
end

return;


% --------------------------------------------------------------------
function ITK_Fast_Symmetric_Demon_Method_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ITK_Fast_Symmetric_Demon_Method_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Select_Registration_Algorithm(hObject,33,handles);
return;


% --------------------------------------------------------------------
function Window_Level_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Lung_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Lung_Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.window_width = ones(1,7)*1000;
handles.gui_options.window_center = ones(1,7)*500;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
handles = Logging(handles,'Using window setting for lung');

guidata(handles.gui_handles.figure1,handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;


% --------------------------------------------------------------------
function Default_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
handles = Use_Default_Window_Level(handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Abdominal_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Abdominal_Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.window_width = ones(1,7)*600;
handles.gui_options.window_center = ones(1,7)*1050;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
handles = Logging(handles,'Using window setting for abdominal');
guidata(handles.gui_handles.figure1,handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;


% --------------------------------------------------------------------
function Difference_Image_Range_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Difference_Image_Range_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Max value (0 = default)'};
name='Set Difference Image Colormap Range';
numlines=1;
defaultanswer={num2str(handles.gui_options.difference_image_range)};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	difference_image_range = str2num(answer{1});
	if difference_image_range ~= handles.gui_options.difference_image_range
		handles.gui_options.difference_image_range = difference_image_range;
		guidata(handles.gui_handles.figure1,handles);
		ConditionalRefreshDisplay(handles,[6 7 19 20]);
	end
end
return;


% --------------------------------------------------------------------
function Deform_Contour_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Deform_Contour_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if ~isempty(handles.reg.dvf.x) && isequal(size(handles.images(2).image),size(handles.reg.dvf.x))
% 	if ~isequal(size(handles.images(1).image),size(handles.images(2).image))
% 		[mvyL,mvxL,mvzL]=expand_motion_field(handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z,size(handles.images(1).image),handles.reg.images_setting.image_offsets);
% 		handles.reg.deformed_structure_masks = deform_structure_masks(handles.images(1).structure_mask,mvyL,mvxL,mvzL);
% 	else
% 		handles.reg.deformed_structure_masks = deform_structure_masks(handles.images(1).structure_mask,handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z);
% 	end
% 	handles = Logging(handles,'Deform structure contours using the computed motion field');
% 	guidata(handles.gui_handles.figure1,handles);
% 	RefreshDisplay(handles);
% 	setinfotext('Contours on image #1 is deformed');
% end


% --------------------------------------------------------------------
function Popup2_Colormaped_Difference_Before_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Colormaped_Difference_Before_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 19, handles);
return;

% --------------------------------------------------------------------
function Popup2_Colormaped_Difference_After_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Colormaped_Difference_After_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupmenu2_show_selection_menu_item_callback(hObject, 20, handles);
return;


% --------------------------------------------------------------------
function Nonlinear_Histogram_Adjustment_For_Lung_Menu_Item_Callback(hObject, eventdata, handles)
Preprocessing_Images(handles,'Nonlinear_Histogram_Adjustment_For_Lung');
return;

% --------------------------------------------------------------------
function Intensity_Modulation_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Intensity_Modulation_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reg.Intensity_Modulation = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Reset_Registration_Results_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Registration_Results_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = RemoveUndoInfo(handles);
handles = Clear_Results(handles);
handles = Logging(handles,'Registration results are reset');
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
setinfotext('Images have been reset and all resutls are cleared');
set(handles.gui_handles.figure1,'Name',handles.info.name);


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
KeyPressFcn_Callback(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Popup2_Export_View3DGUI_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Export_View3DGUI_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = FindCurrentAxes(handles);
if idx < 1
	return;
end

if handles.gui_options.display_enabled(idx) == 0
	return;
end

displaymode = handles.gui_options.display_mode(idx,2);
try
	switch displaymode
		case 1
			img3d = handles.images(1).image;
		case {2,3}
			img3d = handles.images(2).image;
		case 4
			img3d = handles.images(1).image_deformed;
		case 5
			img3d = handles.images(2).image_deformed;
		case {6,8,19}
			img3d = handles.images(1).image - handles.images(2).image;
		case {7,9,20}
			img3d = handles.images(1).image_deformed - handles.images(2).image;
		case 10	% Jacobian of the deformation field
			img3d = handles.reg.jacobian;
		case 14	% Motion field X
			img3d = handles.reg.dvf.x;
		case 15	% Motion field Y
			img3d = handles.reg.dvf.y;
		case 16	% Motion field Z
			img3d = handles.reg.dvf.z;
		case 17	% Motion field abs
			img3d = sqrt(handles.reg.dvf.x.^2+handles.reg.dvf.y.^2+handles.reg.dvf.z.^2);
	end

	ratio = handles.images(1).voxelsize/min(handles.images(1).voxelsize);
	view3dgui(img3d,ratio);
catch
end

return;

% --------------------------------------------------------------------
function Regional_Smoothing_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Regional_Smoothing_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(get(handles.gui_handles.Registration_Framework_Menu,'child'),'checked','off');
set(hObject,'checked','on');
handles.reg.registration_framework = 'region_smoothing';
guidata(handles.gui_handles.figure1,handles);

return;


% --------------------------------------------------------------------
function Use_Both_Image_Gradients_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Use_Both_Image_Gradients_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reg.Use_Both_Image_Gradients = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Preprocessing_Undo_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Preprocessing_Undo_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'undo_handles')
	handles = handles.undo_handles;
% 	handles = configure_sliders(handles);
	handles = Logging(handles,'Undo the last step');
	guidata(handles.gui_handles.figure1,handles);	
	RefreshDisplay(handles);
end
setinfotext('Results are undone');
set(handles.gui_handles.figure1,'Name',handles.info.name);

return;




% --------------------------------------------------------------------
function Options_Display_Deformed_Structure_Contours_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Display_Deformed_Structure_Contours_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
ConditionalRefreshDisplay(handles,[1:9 19 20]);
return;


% --------------------------------------------------------------------
function Use_Current_Results_and_Continue_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Use_Current_Results_and_Continue_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
return;


% --------------------------------------------------------------------
function Smooth_Deformed_Contours_Menu_Item_Callback(hObject, eventdata, handles)
Smooth_Deformed_Contours_Callback(handles);
return;


% --------------------------------------------------------------------
function Print_Logs_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Print_Logs_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.info,'log') && ~isempty(handles.info.log)
	fprintf('\n\n===========================================\n');
	fprintf('=======        Event Logs       ===========\n');
	fprintf('===========================================\n');
	
	str1 = 'Update image offsets manually from keyboard';
	for k = 1:length(handles.info.log)
		str = handles.info.log{k};
		if k < length(handles.info.log) && ~isempty(findstr(str1,str)) && ~isempty(findstr(str1,handles.info.log{k+1}))
			continue;
		else
			fprintf('%d:\t%s\n',k,str);
		end
	end
	fprintf('===========================================\n\n\n');
else
	fprintf('There is no logged message to print\n');
end
return


% --------------------------------------------------------------------
function Load_Image_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Image_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Expand_Structure_Masks_Menu_Item_Callback(hObject, eventdata, handles)
% Expand_Structure_Masks_Callback(handles);
return;


% --------------------------------------------------------------------
function Smooth_Motion_Field_Menu_Item_Callback(hObject, eventdata, handles)
Smooth_Motion_Field_Callback(handles);
return;

% --------------------------------------------------------------------
function Pad_Image_Menu_Item_Callback(hObject, eventdata, handles)
Pad_Image_Callback(handles);
return;


% --------------------------------------------------------------------
function Pad_Smaller_Image_Menu_Item_Callback(hObject, eventdata, handles)
Pad_Smaller_Image_Callback(handles);
return;


% --------------------------------------------------------------------
function Delete_Couch_Table_Menu_Item_Callback(hObject, eventdata, handles)
Delete_Couch_Table_Callback(handles);
return;


% --------------------------------------------------------------------
function Not_Deform_Regions_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Not_Deform_Regions_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
return;


% --------------------------------------------------------------------
function Paint_Image_Menu_Item_Callback(hObject, eventdata, handles)
Paint_Image_Callback(handles);
return;


% --------------------------------------------------------------------
function Save_Processed_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Processed_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

processed_images = handles.images;
save temp_processed_images.mat processed_images;
setinfotext('Processed images are saved into temp_processed_images.mat');

% --------------------------------------------------------------------
function Load_Processed_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Processed_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if exist('temp_processed_images.mat','file')
	load temp_processed_images.mat;
	handles.images = processed_images;
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
	setinfotext('Processed images are loaded from temp_processed_images.mat');
end


% --------------------------------------------------------------------
function Experimental_Steps_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Experimental_Steps_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Patch_Images_Using_Structures_Masks_Menu_Item_Callback(hObject, eventdata, handles)
% Patch_Images_Using_Structures_Masks_Callback(handles);
Patch_Images_with_ART_Structure(handles);
return;


% --------------------------------------------------------------------
function Extend_Image_2_SI_Menu_Item_Callback(hObject, eventdata, handles)
Extend_Image_2_SI_Callback(handles);
return;


% --------------------------------------------------------------------
function Using_Masks_To_Replace_Images_Menu_Item_Callback(hObject, eventdata, handles)
error('check me here');
Using_Masks_To_Replace_Images_Callback(handles);
return;


% --------------------------------------------------------------------
function Options_Draw_Box_For_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Draw_Box_For_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_boundary_boxes',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% ConditionalRefreshDisplay(handles,[1 3 4 6:9 19 20]);
return;


% --------------------------------------------------------------------
function Option_Display_Structure_Contours_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_Structure_Contours_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Options_Display_Structure_Contour_2_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Display_Structure_Contour_2_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = Check_MenuItem(hObject,1);
if val == 1
	set(handles.gui_handles.Display_Structure_In_Own_View_Menu_Item,'checked','off');
end

if handles.gui_options.lock_between_display == 1
	handles.gui_options.display_contour_2_in_all_views(:) = val;
	if val == 1
		handles.gui_options.display_contour_in_own_view(:) = 0;
	end
	ConditionalRefreshDisplay(handles,[1:9 19 20]);
else
	handles.gui_options.display_contour_2_in_all_views(handles.gui_options.current_axes_idx) = val;
	if val == 1
		handles.gui_options.display_contour_in_own_view(handles.gui_options.current_axes_idx) = 0;
	end
	update_display(handles,handles.gui_options.current_axes_idx);
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Activity_Logs_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Activity_Logs_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Add_A_Note_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Add_A_Note_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = ['Note'];
name=sprintf('Add a note to the activity log');
numlines=1;
defaultanswer={''};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	return;
end

handles = Logging(handles,answer{1});
guidata(handles.gui_handles.figure1,handles);

return;


% --------------------------------------------------------------------
function Delete_A_Note_By_Number_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_A_Note_By_Number_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.info.log)
	prompt = ['Note # to delete'];
	name=sprintf('Delete a logged note');
	numlines=1;
	defaultanswer={num2str(length(handles.info.log))};
	options.Resize = 'on';
	answer=inputdlg(prompt,name,numlines,defaultanswer,options);

	if isempty(answer)
		return;
	end

	no = round(str2num(answer{1}));
	
	if no < 1
		return;
	elseif no == 1
		handles.info.log = handles.info.log(2:end);
	elseif no < length(handles.info.log)
		handles.info.log = handles.info.log([1:(no-1) (no+1):end]);
	elseif no == length(handles.info.log)
		handles.info.log = handles.info.log(1:(endno-1));
	else
		return;
	end
		
	handles = Logging(handles,answer{1});
	guidata(handles.gui_handles.figure1,handles);
end

return;

% --------------------------------------------------------------------
function Clear_All_Notes_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_All_Notes_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = rmfield(handles,'log');
guidata(handles.gui_handles.figure1,handles);
return;


% --------------------------------------------------------------------
function Flip_Images_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Flip_Images_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Further_Motion_Field_Processing_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Further_Motion_Field_Processing_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Apply_Structure_Masks_2_Menu_Item_Callback(hObject, eventdata, handles)
Apply_Structure_Masks_2_Callback(handles);
return;


% --------------------------------------------------------------------
function Mark_MVCT_FOV_As_NaN_Menu_Item_Callback(hObject, eventdata, handles)
Mark_MVCT_FOV_As_NaN_Callback(handles);
return;

% --------------------------------------------------------------------
function Change_NaN_Voxels_Menu_Item_Callback(hObject, eventdata, handles)
Change_NaN_Voxels_Callback(handles);
return;


% --------------------------------------------------------------------
function Options_Contour_Line_Thickness_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Contour_Line_Thickness_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = handles.gui_options.current_axes_idx;
prompt = ['Contour Line Thickness in pixels :'];
name='Contour Line Thickness';
numlines=1;
defaultanswer={num2str(handles.gui_options.contour_line_thickness(idx))};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if ~isempty(answer)
	thickness = str2double(answer{1});
	thickness = max(thickness,0.5);
	if thickness ~= handles.gui_options.contour_line_thickness(idx)
		if handles.gui_options.lock_between_display == 1
			handles.gui_options.contour_line_thickness(:) = thickness;
			RefreshDisplay(handles);
		else
			handles.gui_options.contour_line_thickness(idx) = thickness;
			update_display(handles,idx);
		end
		guidata(handles.gui_handles.figure1,handles);
	end
end

return;
	


% --------------------------------------------------------------------
function Add_Subtract_Constant_Value_Menu_Item_Callback(hObject, eventdata, handles)
Add_Subtract_Constant_Value_Callback(handles);
return;


% --------------------------------------------------------------------
function Extended_Images_in_SI_Menu_Item_Callback(hObject, eventdata, handles)
Extended_Images_in_SI_Callback(handles);
return;



% --------------------------------------------------------------------
function Options_Draw_Nan_Boundaries_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Draw_Nan_Boundaries_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'display_NaN_boxes',Check_MenuItem(hObject,1));
% Check_MenuItem(hObject,1);
% if sum(isnan(handles.images(1).image(:)))>0 || sum(isnan(handles.images(2).image(:))) > 0
% 	RefreshDisplay(handles);
% end
return;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.images(1).image)
	return;
end

[idx,haxes] = FindCurrentAxes(handles);
if handles.gui_options.display_enabled(idx) == 0
	return;
end

SelectionType = get(hObject,'SelectionType');
current_mouse_point = round(get(haxes, 'currentPoint'));
xa = get(haxes,'xlim');
ya = get(haxes,'ylim');
if current_mouse_point(1,1) < xa(1) || current_mouse_point(1,1) > xa(2) ||  ...
	current_mouse_point(1,2) < ya(1) || current_mouse_point(1,2) > ya(2) || ...
	strcmpi(SelectionType,'alt') == 1
	return;
end

% Set the slider position and GUI menus
handles = SetActivePanel(handles,idx);

handles.gui_options.button_down_axis_idx = idx;
handles.gui_options.current_axes_idx = idx;
handles.gui_handles.button_down_axis = haxes;
handles.gui_options.current_mouse_point = current_mouse_point;
guidata(handles.gui_handles.figure1,handles);

if Check_MenuItem(handles.gui_handles.Mouse_Button_Action_Window_Level_Adjustment_Menu_Item,0) == 1
	set(handles.gui_handles.figure1, 'WindowButtonUpFcn', 'reg3dgui(''figure1_WindowButtonUpFcn'',gcbo,[],guidata(gcbo))');
	set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', 'reg3dgui(''figure1_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))');
elseif Check_MenuItem(handles.gui_handles.Mouse_Button_Action_Zoom_Menu_Item,0) == 1
	[control,shift]=CheckKeyModifiers(handles);
	if shift == 1
		ZoomDisplay(handles,2,current_mouse_point);
	else
		ZoomDisplay(handles,1,current_mouse_point);
	end
elseif Check_MenuItem(handles.gui_handles.Mouse_Button_Action_Pan_Menu_Item,0) == 1
	set(handles.gui_handles.figure1, 'WindowButtonUpFcn', 'reg3dgui(''figure1_WindowButtonUpFcn_Move_Display'',gcbo,[],guidata(gcbo))');
	set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', 'reg3dgui(''figure1_WindowButtonMotionFcn_Move_Display'',gcbo,[],guidata(gcbo))');
% 	MoveDisplay(handles,current_mouse_point);
elseif Check_MenuItem(handles.gui_handles.Mouse_Button_Action_Slice_Changing_Menu_Item,0) == 1
	set(handles.gui_handles.figure1, 'WindowButtonUpFcn', 'reg3dgui(''figure1_WindowButtonUpFcn_Change_Slice'',gcbo,[],guidata(gcbo))');
	set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', 'reg3dgui(''figure1_WindowButtonMotionFcn_Change_Slice'',gcbo,[],guidata(gcbo))');
	labeltag = findobj(handles.gui_handles.figure1,'tag',['label' num2str(idx)]);
	dim = GetImageDisplayDimensionAndOffsets(handles);
	viewdir = handles.gui_options.display_mode(idx,1);
	set(labeltag,'string',sprintf('%d / %d',handles.gui_options.slidervalues(idx,viewdir),dim(viewdir)));
elseif Check_MenuItem(handles.gui_handles.Mouse_Button_Action_Image_Alignment_Menu_Item,0) == 1
	Align_Image_Mouse(handles,current_mouse_point);
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;

if ~isempty(whos('global','reg3dgui_mouse_in_motion'))
	global reg3dgui_mouse_in_motion;
else
	global reg3dgui_mouse_in_motion;
	reg3dgui_mouse_in_motion = 0;
end

if reg3dgui_mouse_in_motion > 0 
	return;
else
	reg3dgui_mouse_in_motion = 1;
end

current_mouse_point = round(get(handles.gui_handles.button_down_axis, 'currentPoint'));
x = current_mouse_point(1,1);
y = current_mouse_point(1,2);
x0 = handles.gui_options.current_mouse_point(1,1);
y0 = handles.gui_options.current_mouse_point(1,2);

% handles.gui_options.current_mouse_point = current_mouse_point;

if any( handles.gui_options.display_mode(handles.gui_options.button_down_axis_idx,2) == [1 2 4 5 6 7 10 14:17] )
	CLow = get(handles.gui_handles.button_down_axis,'clim');
	CHigh = CLow(2);
	CLow = CLow(1);
	CStep = handles.reg.images_setting.max_intensity_value/2000;
	if any( handles.gui_options.display_mode(handles.gui_options.button_down_axis_idx,2) == [14:17] )
		CStep = 0.01;
	end
		
	CLow = CLow + CStep*(x-x0);
	CHigh = CHigh + CStep*(x-x0);
	CHigh = CHigh + CStep*(y-y0);
	CLow = CLow - CStep*(y-y0);
	CHigh = max(CHigh,CLow*1.01);
	set(handles.gui_handles.button_down_axis,'clim',[CLow CHigh]);
	reg3dgui_global_windows_centers(handles.gui_options.button_down_axis_idx) = (CLow+CHigh)/2;
	reg3dgui_global_windows_widths(handles.gui_options.button_down_axis_idx) = (CHigh-CLow);
end

reg3dgui_mouse_in_motion = 0;

return;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gui_handles.figure1, 'WindowButtonUpFcn', '');
set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', '');
global reg3dgui_mouse_in_motion;
reg3dgui_mouse_in_motion = 0;



% --- Executes on mouse motion over figure - except title and menu.
function newsliceno = figure1_WindowButtonMotionFcn_Change_Slice(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = handles.gui_options.button_down_axis_idx;
current_mouse_point = round(get(handles.gui_handles.button_down_axis, 'currentPoint'));
x = current_mouse_point(1,1);
x0 = handles.gui_options.current_mouse_point(1,1);

labeltag = findobj(handles.gui_handles.figure1,'tag',['label' num2str(idx)]);
dim = GetImageDisplayDimensionAndOffsets(handles);
viewdir = handles.gui_options.display_mode(idx,1);
maxd = dim(viewdir);
newsliceno = handles.gui_options.slidervalues(idx,viewdir) + round(x-x0);
newsliceno = max(newsliceno,1);
newsliceno = min(newsliceno,maxd);
set(handles.gui_handles.sliderhandles(viewdir),'value',newsliceno);
set(labeltag,'string',sprintf('%d / %d',newsliceno,maxd));
return;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn_Change_Slice(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gui_handles.figure1, 'WindowButtonUpFcn', '');
set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', '');
newsliceno = figure1_WindowButtonMotionFcn_Change_Slice(hObject, eventdata, handles);
idx = handles.gui_options.button_down_axis_idx;
viewdir = handles.gui_options.display_mode(idx,1);
set(handles.gui_handles.sliderhandles(viewdir),'value',newsliceno);
handle_sliders(handles.gui_handles.sliderhandles(viewdir),handles,viewdir,1);
global reg3dgui_mouse_in_motion;
reg3dgui_mouse_in_motion = 0;


% --- Executes on mouse motion over figure - except title and menu.
function newsliceno = figure1_WindowButtonMotionFcn_Move_Display(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(whos('global','reg3dgui_mouse_in_motion'))
	global reg3dgui_mouse_in_motion;
else
	global reg3dgui_mouse_in_motion;
	reg3dgui_mouse_in_motion = 0;
end

if reg3dgui_mouse_in_motion > 0 
	return;
else
	reg3dgui_mouse_in_motion = 1;
end

current_mouse_point = get(handles.gui_handles.button_down_axis, 'currentPoint');
MoveDisplay(handles,current_mouse_point,handles.gui_options.current_mouse_point);
reg3dgui_mouse_in_motion = 0;

return;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn_Move_Display(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gui_handles.figure1, 'WindowButtonUpFcn', '');
set(handles.gui_handles.figure1, 'WindowButtonMotionFcn', '');

xlims=get(handles.gui_handles.button_down_axis,'xlim');
ylims=get(handles.gui_handles.button_down_axis,'ylim');

idx = handles.gui_options.current_axes_idx;
viewdir = handles.gui_options.display_mode(idx,1);
displaymode = handles.gui_options.display_mode(idx,2);
limits = handles.gui_options.display_limits(idx,displaymode);

switch viewdir
	case 1
		limits.xlimits = xlims;
		limits.zlimits = ylims;
	case 2
		limits.ylimits = xlims;
		limits.zlimits = ylims;
	case 3
		limits.xlimits = xlims;
		limits.ylimits = ylims;
end
handles.gui_options.display_limits(idx,displaymode) = limits;
guidata(handles.gui_handles.figure1,handles);
update_display(handles,idx);

global reg3dgui_mouse_in_motion;
reg3dgui_mouse_in_motion = 0;

% --------------------------------------------------------------------
function Options_Image_Display_Geometry_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Image_Display_Geometry_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Option_Display_In_Regular_Image_Size_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_In_Regular_Image_Size_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ProcessDisplayLimitSelectionMenu(hObject,1,handles);
return;

% --------------------------------------------------------------------
function Option_Display_In_Fixed_Image_Size_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_In_Fixed_Image_Size_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessDisplayLimitSelectionMenu(hObject,2,handles);
return;

% --------------------------------------------------------------------
function Option_Display_In_Moving_Image_Size_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_In_Moving_Image_Size_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ProcessDisplayLimitSelectionMenu(hObject,3,handles);
return;

% --------------------------------------------------------------------
function Option_Display_In_Combined_Image_Size_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_In_Combined_Image_Size_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ProcessDisplayLimitSelectionMenu(hObject,4,handles);
return;

% --------------------------------------------------------------------
function Option_Display_In_Intersected_Image_Size_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Option_Display_In_Intersected_Image_Size_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ProcessDisplayLimitSelectionMenu(hObject,5,handles);
return;

% --------------------------------------------------------------------
function ProcessDisplayLimitSelectionMenu(hObject,idx,handles)
menuitems = get(handles.gui_handles.Options_Image_Display_Geometry_Menu,'child');
for k = 1:length(menuitems);
	if strcmp(get(menuitems(k),'Checked'),'on')
		break;
	end
end
current_sel = length(menuitems)-k+1;
set(menuitems,'Checked','off');
set(hObject,'Checked','on');
if idx ~= current_sel
	if handles.gui_options.lock_between_display == 1
		handles.gui_options.display_geometry_limit_mode = ones(handles.gui_options.num_panels,1)*idx;
		handles = set_display_geometry_limits(handles);
		guidata(handles.gui_handles.figure1,handles);
		RefreshDisplay(handles);
	else
		handles.gui_options.display_geometry_limit_mode(handles.gui_options.current_axes_idx) = idx;
		handles = set_display_geometry_limits(handles,handles.gui_options.current_axes_idx);
		guidata(handles.gui_handles.figure1,handles);
		update_display(handles,handles.gui_options.current_axes_idx);
	end
end

return;


% --------------------------------------------------------------------
function ART_Tools_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Tools_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.images(1).image)
	set(handles.gui_handles.ART_Contours_Menu,'enable','off');
	set(handles.gui_handles.ART_Dose_Menu,'enable','off');
else
	set(handles.gui_handles.ART_Contours_Menu,'enable','on');
	set(handles.gui_handles.ART_Dose_Menu,'enable','on');
end
% if ~isempty(handles.reg.dvf.x)
% 	set(get(hObject,'child'),'enable','on');
% else
% 	set(get(hObject,'child'),'enable','off');
% end

% --------------------------------------------------------------------
function ART_Contour_Deformation_Menu_Item_Callback(hObject, eventdata, handles)
ART_Contour_Deformation_New(handles);
return;

% --------------------------------------------------------------------
function Export_i1vx_DICOM_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Export_i1vx_DICOM_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Generate_Transformation_Vector_Field_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Generate_Transformation_Vector_Field_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Options_Display_Color_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Display_Color_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Other_Display_Options_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Other_Display_Options_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Bones_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Bones_Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.window_center = ones(1,7)*1400;
handles.gui_options.window_width = ones(1,7)*1500;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
handles = Logging(handles,'Using window setting for bones');
guidata(handles.gui_handles.figure1,handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);


% --------------------------------------------------------------------
function HN_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to HN_Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.window_center = ones(1,7)*1045;
handles.gui_options.window_width = ones(1,7)*125;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
handles = Logging(handles,'Using window setting for head-neck');
guidata(handles.gui_handles.figure1,handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);


% --------------------------------------------------------------------
function Liver_Window_Level_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Liver_Window_Level_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.gui_options.window_center = ones(1,7)*1080;
handles.gui_options.window_width = ones(1,7)*305;
global reg3dgui_global_windows_centers reg3dgui_global_windows_widths;
reg3dgui_global_windows_centers = handles.gui_options.window_center;
reg3dgui_global_windows_widths = handles.gui_options.window_width;
handles = Logging(handles,'Using window setting for head-neck');
guidata(handles.gui_handles.figure1,handles);
ConditionalRefreshDisplay(handles,[1:9 19 20]);

% --------------------------------------------------------------------
function Set_Colormap_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Colormap_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mapselected = SelectColormap(handles.gui_options.colormap);
if ~isempty(mapselected)
	handles.gui_options.colormap = mapselected;
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

%--------------------------------------------------------------------
function KeyPressFcn_Callback(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyPressed = get(hObject, 'CurrentCharacter');
% keyValue = uint8(keyPressed);
keyname = get(hObject, 'currentKey');
modifier = get(hObject, 'CurrentModifier');

control = 0;
shift = 0;
modifiers = length(modifier);
if modifiers
	for k = 1:modifiers
		switch modifier{k}
			case 'control'
				control = 1;
			case 'shift'
				shift = 1;
		end
	end
end

if modifiers == 0
	switch upper(keyPressed)
		case 'C'	% color display on/off
			OptionsDisplayColorMenuItem_Callback(handles.gui_handles.OptionsDisplayColorMenuItem,eventdata,handles);
		case '1'	% Coronal view
			Coronal_View_Menu_Item_Callback(handles.gui_handles.Coronal_View_Menu_Item,eventdata,handles);
		case '2'	% Sagittal view
			Sagittal_View_Menu_Item_Callback(handles.gui_handles.Sagittal_View_Menu_Item,eventdata,handles);
		case '3'	% Transverse view
			Transverse_View_Menu_Item_Callback(handles.gui_handles.Transverse_View_Menu_Item,eventdata,handles);
		case '4'	% T/C/S view
			T_C_S_View_Menu_Item_Callback(handles.gui_handles.T_C_S_View_Menu_Item,eventdata,handles);
		case '5'	% T/C/S difference view
			T_C_S_Difference_View_Menu_Item_Callback(handles.gui_handles.T_C_S_Difference_View_Menu_Item,eventdata,handles);
		case {'Z'}
			Mouse_Button_Action_Zoom_Menu_Item_Callback(handles.gui_handles.Mouse_Button_Action_Zoom_Menu_Item, eventdata, handles);
		case {'S'}
			Mouse_Button_Action_Slice_Changing_Menu_Item_Callback(handles.gui_handles.Mouse_Button_Action_Slice_Changing_Menu_Item, eventdata, handles);
		case {'M'}
			Mouse_Button_Action_Pan_Menu_Item_Callback(handles.gui_handles.Mouse_Button_Action_Pan_Menu_Item, eventdata, handles);
		case {'W'}
			Mouse_Button_Action_Window_Level_Adjustment_Menu_Item_Callback(handles.gui_handles.Mouse_Button_Action_Window_Level_Adjustment_Menu_Item, eventdata, handles);
		case {'L'}
			GUIOptions_Lock_Display_Menu_Item_Callback(handles.gui_handles.GUIOptions_Lock_Display_Menu_Item, eventdata, handles);
		case '0'
			% zoom reset
			ZoomDisplay(handles,0);
		case '9'
			Paint_Image_Menu_Item_Callback(handles.gui_handles.Paint_Image_Menu_Item, eventdata, handles);
		otherwise
			curAxes = handles.gui_options.current_axes_idx;
			viewdir = handles.gui_options.display_mode(curAxes,1);
			dim2 = GetImageDisplayDimensionAndOffsets(handles,handles.gui_options.display_mode(curAxes,2));

			newval = handles.gui_options.slidervalues(curAxes,viewdir);
			switch lower(keyname)
				case {'uparrow','leftarrow'}
					if newval > 1
						newval = newval-1;
					end
				case {'downarrow','rightarrow'}
					if newval < dim2(viewdir)
						newval = newval+1;
					end
				case {'pageup'}
					if newval > 1
						newval = max(1,newval-5);
					end
				case 'pagedown'
					if newval < dim2(viewdir)
						newval = min(dim2(viewdir),newval+5);
					end
				case 'home'
					newval = 1;
				case 'end'
					newval = dim2(viewdir);
			end
			if newval ~= handles.gui_options.slidervalues(curAxes,viewdir)
				set(handles.gui_handles.sliderhandles(viewdir),'value',newval);
				handle_sliders(handles.gui_handles.sliderhandles(viewdir),handles,viewdir);
			end
	end
elseif control == 1 && ~strcmp(keyname,'control') && ~strcmp(keyname,'shift')
	switch upper(keyPressed)
		% window level shortcut keys
		case 'L'
			Lung_Window_Level_Menu_Item_Callback(handles.gui_handles.Lung_Window_Level_Menu_Item,eventdata,handles);
		case 'R'
			Default_Window_Level_Menu_Item_Callback(handles.gui_handles.Default_Window_Level_Menu_Item,eventdata,handles);
		case 'O'
			Abdominal_Window_Level_Menu_Item_Callback(handles.gui_handles.Abdominal_Window_Level_Menu_Item,eventdata,handles);
		case 'M'
			ProcessMotionSelectionMenu(handles.gui_handles.OverallMotionMenuItem,2,handles);
		case 'H'
			ProcessMotionSelectionMenu(handles.gui_handles.Hide_Motion_Menu_Item,1,handles);
			% 	case 'p'
			% 	Options_Show_Pixel_Information_Menu_Item_Callback(handles.gui_handles.Options_Show_Pixel_Information_Menu_Item,[],handles);
		otherwise
			if isfield(handles,'images') && Check_MenuItem(handles.gui_handles.Allow_Offset_Change_Menu_Item,0) == 1
				image_offsets = handles.reg.images_setting.image_offsets;
				step = 1;
				if shift == 1
					step = 5;
				end
				switch lower(keyname)
					case 'pagedown'
						image_offsets(3) = image_offsets(3)-step;
					case {'pageup'}
						image_offsets(3) = image_offsets(3)+step;
					case {'uparrow'}
						image_offsets(1) = image_offsets(1)+step;
					case {'downarrow'}
						image_offsets(1) = image_offsets(1)-step;
					case {'rightarrow'}
						image_offsets(2) = image_offsets(2)-step;
					case {'leftarrow'}
						image_offsets(2) = image_offsets(2)+step;
				end
				ChangeAlignment(handles,image_offsets);
			end
	end
end


% --------------------------------------------------------------------
function GUIOptions_Lock_Display_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to GUIOptions_Lock_Display_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.gui_options.lock_between_display = Check_MenuItem(hObject,1);
guidata(handles.gui_handles.figure1,handles);
if handles.gui_options.lock_between_display == 1
	GUIOptions_Aign_Between_Windows_Menu_Item_Callback(handles.gui_handles.GUIOptions_Aign_Between_Windows_Menu_Item, eventdata, handles);
end

% --------------------------------------------------------------------
function GUIOptions_Aign_Between_Windows_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to GUIOptions_Aign_Between_Windows_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% idx = FindCurrentAxes(handles);
idx = handles.gui_options.current_axes_idx;
if handles.gui_options.display_enabled(idx) == 0
	return;
end

handles = SetSlidersValueForOtherDisplays(handles,idx,1);
handles = SetSlidersValueForOtherDisplays(handles,idx,2);
handles = SetSlidersValueForOtherDisplays(handles,idx,3);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

return;





% --------------------------------------------------------------------
function Mouse_Button_Actions_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Actions_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles)
checked = get(hObject,'checked');
set(get(handles.gui_handles.Mouse_Button_Actions_Menu,'child'),'checked','off');
if strcmpi(checked,'on') == 1
	set(hObject,'checked','off');
	set(handles.gui_handles.figure1,'Pointer','arrow')
	on = 0;
else
	set(hObject,'checked','on');
	on = 1;
end

% --------------------------------------------------------------------
function Mouse_Button_Action_Window_Level_Adjustment_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Action_Window_Level_Adjustment_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles);
if on == 1
	load contrast_pointer.mat;
	set(handles.gui_handles.figure1,'Pointer','custom','PointerShapeCData',cdata)
end

% --------------------------------------------------------------------
function Mouse_Button_Action_Zoom_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Action_Zoom_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles);
if on == 1
	load zoom_pointer.mat;
	set(handles.gui_handles.figure1,'Pointer','custom','PointerShapeCData',cdata)
end


% --------------------------------------------------------------------
function Mouse_Button_Action_Pan_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Action_Pan_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles);
if on == 1
	load hand_pointer.mat;
	set(handles.gui_handles.figure1,'Pointer','custom','PointerShapeCData',cdata)
end


% --------------------------------------------------------------------
function Mouse_Button_Action_Slice_Changing_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Action_Slice_Changing_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles);
if on == 1
	load hand_pointer_s.mat;
	set(handles.gui_handles.figure1,'Pointer','custom','PointerShapeCData',cdata)
end

% --------------------------------------------------------------------
function Mouse_Button_Action_Image_Alignment_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Mouse_Button_Action_Image_Alignment_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
on = Handle_Mouse_Button_Action_Menu_Items(hObject,handles);
if on == 1
	load hand_pointer_r.mat;
	set(handles.gui_handles.figure1,'Pointer','custom','PointerShapeCData',cdata)
end

% --------------------------------------------------------------------
function Popup2_Zoom_Reset_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup2_Zoom_Reset_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = FindCurrentAxes(handles);
handles.gui_options.current_axes_idx = idx;
ZoomDisplay(handles,0);

% --------------------------------------------------------------------
function ART_Contours_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Contours_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = length(handles.ART.structures);
if isempty(handles.ART.structures)
	set(handles.gui_handles.ART_Contour_Deformation_Menu_Item,'enable','off');
	set(handles.gui_handles.ART_Structure_Color_List_Menu_Item,'enable','off');
% 	set(handles.gui_handles.ART_Structure_Export_Menu_Item,'enable','off');
	set(handles.gui_handles.Add_Structures_To_PlanC_Menu_Item,'enable','off');
else
	set(handles.gui_handles.ART_Contour_Deformation_Menu_Item,'enable','on');
	set(handles.gui_handles.ART_Structure_Color_List_Menu_Item,'enable','on');
% 	set(handles.gui_handles.ART_Structure_Export_Menu_Item,'enable','on');
	set(handles.gui_handles.Add_Structures_To_PlanC_Menu_Item,'enable','on');
end
if N < 2
	set(handles.gui_handles.Compare_Two_Structures_Menu_Item,'enable','off');
else
	set(handles.gui_handles.Compare_Two_Structures_Menu_Item,'enable','on');
end

% --------------------------------------------------------------------
function ART_Dose_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Dose_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gui_handles.ART_Save_Dose_DICOMRT_Menu_Item,'enable','off');
set(handles.gui_handles.ART_Dose_Deformation_Menu_Item,'enable','off');
set(handles.gui_handles.ART_Dose_Manager_Menu_Item,'enable','off');
set(handles.gui_handles.Add_Dose_to_CERR_Plan_Menu_Item,'enable','off');
if ~isempty(handles.ART.dose)
	set(handles.gui_handles.ART_Dose_Manager_Menu_Item,'enable','on');
	set(handles.gui_handles.ART_Save_Dose_DICOMRT_Menu_Item,'enable','on');
	set(handles.gui_handles.Add_Dose_to_CERR_Plan_Menu_Item,'enable','on');
	if ~isempty(handles.reg.dvf.x)
		set(handles.gui_handles.ART_Dose_Deformation_Menu_Item,'enable','on');
	end
end


% --------------------------------------------------------------------
function ART_Load_Dose_DICOMRT_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Load_Dose_DICOMRT_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dose = Load_Dose_DICOMRT;
if ~isempty(dose)
% 	dose = GetAssociatedImageIdx(handles,dose);
	dose.association = GetAssociatedImageIdx(handles,dose.assocScanUID);
	Add1Dose(handles,dose);
end

% --------------------------------------------------------------------
function ART_Save_Dose_DICOMRT_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Save_Dose_DICOMRT_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SaveDoseDICOMRT(handles);

% --------------------------------------------------------------------
function ART_Structure_Export_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Structure_Export_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Dose_Menu_Callback(hObject, eventdata, handles)

% hObject    handle to Dose_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Dose_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
if ~isempty(handles.ART.dose)
	RefreshDisplay(handles);
end


% --------------------------------------------------------------------
function ART_Load_Dose_From_CERR_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Load_Dose_From_CERR_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dose = Load_Dose_CERR;
if ~isempty(dose)
% 	dose = GetAssociatedImageIdx(handles,dose);
	dose.association = GetAssociatedImageIdx(handles,dose.assocScanUID);
	Add1Dose(handles,dose);
end


% --------------------------------------------------------------------
function ART_Dose_Manager_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Dose_Manager_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% h = openfig('DoseManager.fig');
h = DoseManager(handles);
uiwait;
if ishandle(h)
	h2 = guidata(h);
	close(h);

	if h2.cancel == 0 && ~isequalwithequalnans(handles.ART.dose,h2.dose)
		doseidx = WhichDoseToDisplay(handles);
		handles.ART.dose = h2.dose;
		guidata(handles.gui_handles.figure1,handles);
		GenerateDoseMenu(handles);
		handles.gui_options.DoseDisplayOptions.dose_to_display(:) = 0;
		if sum(doseidx) > 0
			RefreshDisplay(handles);
		end
	end
end


% --------------------------------------------------------------------
function ART_Dose_Deformation_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Dose_Deformation_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Dose_Deformation(handles);

% --------------------------------------------------------------------
function Define_3D_ROI_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Define_3D_ROI_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Define_3D_ROI(handles,1,1);
return;

% --------------------------------------------------------------------
function Popup_Message_Box_Clear_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_Message_Box_Clear_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.gui_handles.infotext,'string','');

% --------------------------------------------------------------------
function Popup_Menu_Message_Box_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_Menu_Message_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Dose_Display_Options_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Display_Options_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Dose_Display_Options_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Display_Options_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = DoseDisplayOptionsUI(handles);
uiwait;
if ishandle(h)
	h2 = guidata(h);
	close(h);

	if h2.cancel == 0 && ~isequal(handles.gui_options.DoseDisplayOptions,h2.DoseDisplayOptions)
		doseidx = WhichDoseToDisplay(handles);
		handles.gui_options.DoseDisplayOptions = h2.DoseDisplayOptions;
		guidata(handles.gui_handles.figure1,handles);
		if doseidx > 0
			if handles.gui_options.lock_between_display == 1
				RefreshDisplay(handles);
			else
				update_display(handles,handles.gui_options.current_axes_idx);
			end
		end
	end
end

% --------------------------------------------------------------------
function Dose_Display_Isodose_Lines_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Display_Isodose_Lines_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = Check_MenuItem(hObject,1);
idx = handles.gui_options.current_axes_idx;
if handles.gui_options.lock_between_display == 1
	handles.gui_options.DoseDisplayOptions.display_isodose_lines(:) = val;
	if sum(WhichDoseToDisplay(handles)) > 0
		RefreshDisplay(handles);
	end
else
	handles.gui_options.DoseDisplayOptions.display_isodose_lines(idx) = val;
	if WhichDoseToDisplay(handles,idx) > 0
		update_display(handles,idx);
	end
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Dose_Display_Colorwash_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Display_Colorwash_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = Check_MenuItem(hObject,1);
idx = handles.gui_options.current_axes_idx;
if handles.gui_options.lock_between_display == 1
	handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(:) = val;
	if val == 1
		handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(:) = 0;
		set(handles.gui_handles.Dose_Display_Fill_Color_Menu_Item,'checked','off');
	end
	if sum(WhichDoseToDisplay(handles)) > 0
		RefreshDisplay(handles);
	end
else
	handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(idx) = val;
	if val == 1
		handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(idx) = 0;
		set(handles.gui_handles.Dose_Display_Fill_Color_Menu_Item,'checked','off');
	end
	if WhichDoseToDisplay(handles,idx) > 0
		update_display(handles,idx);
	end
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Dose_Display_Fill_Color_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Display_Fill_Color_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = Check_MenuItem(hObject,1);
idx = handles.gui_options.current_axes_idx;
if handles.gui_options.lock_between_display == 1
	handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(:) = val;
	if val == 1
		handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(:) = 0;
		set(handles.gui_handles.Dose_Display_Colorwash_Menu_Item,'checked','off');
	end
	if sum(WhichDoseToDisplay(handles)) > 0
		RefreshDisplay(handles);
	end
else
	handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor(idx) = val;
	if val == 1
		handles.gui_options.DoseDisplayOptions.display_isodose_colorwash(idx) = 0;
		set(handles.gui_handles.Dose_Display_Colorwash_Menu_Item,'checked','off');
	end
	if WhichDoseToDisplay(handles,idx) > 0
		update_display(handles,idx);
	end
end
guidata(handles.gui_handles.figure1,handles);
return;

% --------------------------------------------------------------------
function Add_Dose_to_CERR_Plan_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Dose_to_CERR_Plan_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AddDoseToPlanC(handles);

% --------------------------------------------------------------------
function ART_Load_Structure_From_CERR_Plan_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Load_Structure_From_CERR_Plan_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR;
if ~isempty(structs)
	handles = AddNewStructures(handles,structs,assocScanIDs,scanInfos);
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('Structures are loaded from a CERR plan');
	RefreshDisplay(handles);
end

% --------------------------------------------------------------------
function Load_Structures_DICOMRT_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Structures_DICOMRT_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Display_Contour_Lines_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Contour_Lines_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'Structure_Draw_Contour_Lines',Check_MenuItem(hObject,1));
% val = Check_MenuItem(hObject,1);
% if handles.gui_options.lock_between_display == 1
% 	handles.gui_options.Structure_Draw_Contour_Lines(:) = val;
% 	RefreshDisplay(handles);
% else
% 	handles.gui_options.Structure_Draw_Contour_Lines(handles.gui_options.current_axes_idx) = val;
% 	update_display(handles,handles.gui_options.current_axes_idx);
% end
% guidata(handles.gui_handles.figure1,handles);


% --------------------------------------------------------------------
function Fill_Structure_Color_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Fill_Structure_Color_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Update_GUI_Option(handles,'Structure_Fill_Color',Check_MenuItem(hObject,1));
% val = Check_MenuItem(hObject,1);
% if handles.gui_options.lock_between_display == 1
% 	handles.gui_options.Structure_Fill_Color(:) = val;
% 	RefreshDisplay(handles);
% else
% 	handles.gui_options.Structure_Fill_Color(handles.gui_options.current_axes_idx) = val;
% 	update_display(handles,handles.gui_options.current_axes_idx);
% end
% guidata(handles.gui_handles.figure1,handles);

% --------------------------------------------------------------------
function Structure_Color_Fill_Transparency_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Structure_Color_Fill_Transparency_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = handles.gui_options.current_axes_idx;
prompt = ['Contour color fill alpha (0 to 1):'];
name='Contour color fill transparency';
numlines=1;
defaultanswer={num2str(handles.gui_options.Structure_Color_Fill_Alpha(idx))};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if ~isempty(answer)
	alpha = str2double(answer{1});
	alpha = max(alpha,0);
	alpha = min(alpha,1);
	if alpha ~= handles.gui_options.Structure_Color_Fill_Alpha(idx)
		if handles.gui_options.lock_between_display == 1
			handles.gui_options.Structure_Color_Fill_Alpha(:) = alpha;
			RefreshDisplay(handles);
		else
			handles.gui_options.Structure_Color_Fill_Alpha(idx) = alpha;
			update_display(handles,idx);
		end
		guidata(handles.gui_handles.figure1,handles);
	end
end

% --------------------------------------------------------------------
function Structure_Manager_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Structure_Manager_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


h = StructureManager(handles);
uiwait;
if ishandle(h)
	h2 = guidata(h);
	close(h);

	if h2.cancel == 0 && ~isequalwithequalnans(handles.ART,h2.ART)
		handles.ART = h2.ART;
		guidata(handles.gui_handles.figure1,handles);
		RefreshDisplay(handles);
	end
end

% --------------------------------------------------------------------
function ART_Structure_Color_List_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to ART_Structure_Color_List_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StructureColorListUI(handles);

% --------------------------------------------------------------------
function Add_Structures_To_PlanC_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Structures_To_PlanC_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ART_Add_Structure_2_PlanC(handles);

% --------------------------------------------------------------------
function Allow_Offset_Change_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Allow_Offset_Change_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if Check_MenuItem(handles.gui_handles.Allow_Offset_Change_Menu_Item,1) == 1
	setinfotext('Realigning images is allowed');
	setinfotext('CTRL + arrow/pageup/pagedown keys are enabled');
else
	setinfotext('CTRL + arrow/pageup/pagedown keys are disabled');
end

% --------------------------------------------------------------------
function MotionColormapMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionColormapMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mapselected = SelectColormap(handles.gui_options.DVF_colormap);
if ~isempty(mapselected) && strcmpi(handles.gui_options.DVF_colormap,mapselected) ~= 1
	handles.gui_options.DVF_colormap = mapselected;
	guidata(handles.gui_handles.figure1,handles);
	if GetMotionDisplayModeSelection(handles) > 3
		RefreshDisplay(handles);
	end
end

% --------------------------------------------------------------------
function MotionXMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionXMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,4,handles);


% --------------------------------------------------------------------
function MotionYMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionYMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,5,handles);


% --------------------------------------------------------------------
function MotionZMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionZMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,6,handles);


% --------------------------------------------------------------------
function MotionXYZMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to MotionXYZMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,7,handles);

% --------------------------------------------------------------------
function Motion_Field_Selection_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Motion_Field_Selection_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(get(hObject,'child'),'enable','on');
if isempty(handles.reg.dvf.x)
	set(handles.gui_handles.Display_Backward_Motion_Menu_Item,'enable','off')
end

if ~isfield(handles.reg,'mvx_resolution')
	set(handles.gui_handles.MotionCurrentResMenuItem,'enable','off')
end

if ~isfield(handles.reg,'mvx_pass')
	set(handles.gui_handles.MotionCurrentPassMenuItem,'enable','off')
end

if ~isfield(handles.reg,'mvx_iteration')
	set(handles.gui_handles.MotionCurrentIterationMenuItem,'enable','off')
end

if isempty(handles.reg.idvf.x)
	set(handles.gui_handles.Display_Forward_Motion_Menu_Item,'enable','off')
end

set(handles.gui_handles.dvf_selection_menu_handles,'checked','off');
sel = handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,1);
% sel = max(1,sel);
set(handles.gui_handles.dvf_selection_menu_handles(sel),'checked','on');


% --------------------------------------------------------------------
function Motion_Display_Mode_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Motion_Display_Mode_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.gui_handles.dvf_mode_menu_handles,'checked','off');
set(handles.gui_handles.dvf_mode_menu_handles(handles.gui_options.DVF_displays(handles.gui_options.current_axes_idx,2)),'checked','on');

if isfield(handles.reg,'jacobian') && ~isempty(handles.reg.jacobian)
	set(handles.gui_handles.Motion_Jacobian_Menu_Item,'enable','on')
else
	set(handles.gui_handles.Motion_Jacobian_Menu_Item,'enable','off')
end

if isfield(handles.reg,'inverse_consistency_errors') && ~isempty(handles.reg.inverse_consistency_errors)
	set(handles.gui_handles.Display_Inverse_Consistency_Error_Menu_Item,'enable','on')
else
	set(handles.gui_handles.Display_Inverse_Consistency_Error_Menu_Item,'enable','off')
end

return;


% --------------------------------------------------------------------
function Display_Backward_Motion_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Backward_Motion_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,1,handles);


% --------------------------------------------------------------------
function Display_Forward_Motion_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Forward_Motion_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionSelectionMenu(hObject,2,handles);

% --------------------------------------------------------------------
function Motion_Jacobian_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Motion_Jacobian_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,8,handles);

% --------------------------------------------------------------------
function File_Image_Alignment_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_Image_Alignment_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if Check_MenuItem(handles.gui_handles.Allow_Offset_Change_Menu_Item,0) == 1
	set(handles.gui_handles.Image_Offset_Menu_Item,'enable','on');
	set(handles.gui_handles.Auto_Align_Images_Menu_Item,'enable','on');
	set(handles.gui_handles.Realign_Images_Menu_Item,'enable','on');
else
	set(handles.gui_handles.Image_Offset_Menu_Item,'enable','off');
	set(handles.gui_handles.Auto_Align_Images_Menu_Item,'enable','off');
	set(handles.gui_handles.Realign_Images_Menu_Item,'enable','off');
end

% --------------------------------------------------------------------
function Realign_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Realign_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles_new = Align_Images_After_Loading(handles);
if ~isequalwithequalnans(handles,handles_new)
	handles=handles_new;
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

% --------------------------------------------------------------------
function T_C_S_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to T_C_S_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_mode(:,1) = [3 2 1 3 3 2 1];
handles.gui_options.display_mode(:,2) = [1 1 1 7 2 2 2];
handles = SetSlidersValueForOtherDisplays(handles);
Panel_Layout_7Sl_Menu_Item_Callback(hObject, eventdata, handles);
setinfotext('Views are changed to T/C/S mode');
return;

% --------------------------------------------------------------------
function T_C_S_Difference_View_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to T_C_S_Difference_View_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.gui_options.display_mode(:,1) = [3 2 1 3 3 2 1];
handles.gui_options.display_mode(:,2) = [19 19 19 3 20 20 20];
handles = SetSlidersValueForOtherDisplays(handles);
Panel_Layout_7Sl_Menu_Item_Callback(hObject, eventdata, handles);
setinfotext('Views are changed to T/C/S mode');
return;

% --------------------------------------------------------------------
function Update_GUI_Option(handles,optionname,val)
if handles.gui_options.lock_between_display == 1
	handles.gui_options.(optionname)(:) = val;
	RefreshDisplay(handles);
else
	handles.gui_options.(optionname)(handles.gui_options.current_axes_idx) = val;
	update_display(handles,handles.gui_options.current_axes_idx);
end
guidata(handles.gui_handles.figure1,handles);


% --------------------------------------------------------------------
function Display_Inverse_Consistency_Error_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Inverse_Consistency_Error_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ProcessMotionModeSelectionMenu(hObject,9,handles);

% --------------------------------------------------------------------
function Compare_Two_Structures_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Compare_Two_Structures_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Compare_Two_Structures(handles);

% --------------------------------------------------------------------
function Start_Registration_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Registration_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start_registration_from_menu(handles.reg.registration_method,handles);

% --------------------------------------------------------------------
function Select_Registration_Algorithm(hObject,method,handles)
handles.reg.registration_method = method;
SetRegAlgorithmSelection(handles); 
set(hObject,'checked','on');
guidata(handles.gui_handles.figure1,handles);
label = get(hObject,'label');
setinfotext(sprintf('%d-"%s" is selected',method,label));

% --------------------------------------------------------------------
function Deform_Fixed_Image_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Deform_Fixed_Image_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter = 'linear';
Deform_Fixed_Image(handles,filter);
return;

% --------------------------------------------------------------------
function Compute_DVF_From_Inverse_DVF_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Compute_DVF_From_Inverse_DVF_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setinfotext('Busy, computing DVF from inverse DVF ...');
% drawnow;
handles_new = InvertDVF(handles,2);
if ~isequalwithequalnans(handles_new,handles)
	handles = handles_new;
	guidata(handles.gui_handles.figure1,handles);
	setinfotext('computing DVF from inverse DVF finished.');
	drawnow;
end
return;


% --------------------------------------------------------------------
function Registration_Framework_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Registration_Framework_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Asymmetric_Registration_Framework_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Asymmetric_Registration_Framework_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(get(handles.gui_handles.Registration_Framework_Menu,'child'),'checked','off');
set(hObject,'checked','on');
handles.reg.registration_framework = 'asymmetric';
guidata(handles.gui_handles.figure1,handles);
% --------------------------------------------------------------------
function Inverse_Consistency_Registration_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Inverse_Consistency_Registration_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map = RegMethod_Menu_Map;
if map(handles.reg.registration_method).inverse_consistency == 0
	msgbox('The selected registration algorithm is not supported by the inverse consistency registration framework.','Warning','warn');
	return;
end
set(get(handles.gui_handles.Registration_Framework_Menu,'child'),'checked','off');
set(hObject,'checked','on');
handles.reg.registration_framework = 'consistency';
guidata(handles.gui_handles.figure1,handles);


% --------------------------------------------------------------------
function DVF_Jacobian_Checking_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to DVF_Jacobian_Checking_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Automatic_Pad_Both_Images_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Automatic_Pad_Both_Images_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Pad_Both_Images(handles);

% --------------------------------------------------------------------
function Dose_Line_2_Structure_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Line_2_Structure_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Dicom_Images_Folder_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Dicom_Images_Folder_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Load_2_Images(handles,4);


% --------------------------------------------------------------------
function Intensity_Transformation_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Intensity_Transformation_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Subtract_local_average_intensity_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Subtract_local_average_intensity_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------
Preprocessing_Images(handles,'subtract_local_average_intensity');
return;

