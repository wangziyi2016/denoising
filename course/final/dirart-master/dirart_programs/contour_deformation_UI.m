function varargout = contour_deformation_UI(varargin)
% CONTOUR_DEFORMATION_UI M-file for contour_deformation_UI.fig
%      CONTOUR_DEFORMATION_UI, by itself, creates a new CONTOUR_DEFORMATION_UI or raises the existing
%      singleton*.
%
%      H = CONTOUR_DEFORMATION_UI returns the handle to a new CONTOUR_DEFORMATION_UI or the handle to
%      the existing singleton*.
%
%      CONTOUR_DEFORMATION_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTOUR_DEFORMATION_UI.M with the given input arguments.
%
%      CONTOUR_DEFORMATION_UI('Property','Value',...) creates a new CONTOUR_DEFORMATION_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before contour_deformation_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to contour_deformation_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help contour_deformation_UI

% Last Modified by GUIDE v2.5 14-Nov-2008 11:52:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @contour_deformation_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @contour_deformation_UI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before contour_deformation_UI is made visible.
function contour_deformation_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to contour_deformation_UI (see VARARGIN)

% Choose default command line output for contour_deformation_UI
handles.output = hObject;
handles.direction = 1;
handles.destination = 2;
handles.smoothing = 1;
handles.use_mesh = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes contour_deformation_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = contour_deformation_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Fixed_Image_Plan_Button.
function Fixed_Image_Plan_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Fixed_Image_Plan_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.planC2 = load_a_CERR_plan('Select the CERR plan of the fixed image');
guidata(handles.figure1,handles);
if ~isempty(handles.planC2)
	idxes = handles.planC2{end};
	if isempty(handles.planC2{idxes.structures})
			uiwait(msgbox('Warning: no structure in the plan'));
	else
		set(handles.Select_Structure_Button,'enable','on');
	end
end



% --- Executes on button press in direction_radiobutton_1.
function direction_radiobutton_1_Callback(hObject, eventdata, handles)
% hObject    handle to direction_radiobutton_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of direction_radiobutton_1

set(hObject,'value',1);
set(handles.direction_radiobutton_2,'value',0);
handles.direction = 1;
guidata(handles.figure1,handles);

% --- Executes on button press in direction_radiobutton_2.
function direction_radiobutton_2_Callback(hObject, eventdata, handles)
% hObject    handle to direction_radiobutton_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of direction_radiobutton_2
set(hObject,'value',1);
set(handles.direction_radiobutton_1,'value',0);
handles.direction = 2;
guidata(handles.figure1,handles);


% --- Executes on button press in destination_radiobutton_1.
function destination_radiobutton_1_Callback(hObject, eventdata, handles)
% hObject    handle to destination_radiobutton_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of destination_radiobutton_1
set(hObject,'value',1);
set(handles.destination_radiobutton_2,'value',0);
handles.destination = 1;
guidata(handles.figure1,handles);

% --- Executes on button press in destination_radiobutton_2.
function destination_radiobutton_2_Callback(hObject, eventdata, handles)
% hObject    handle to destination_radiobutton_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of destination_radiobutton_2
set(hObject,'value',1);
set(handles.destination_radiobutton_1,'value',0);
handles.destination = 2;
guidata(handles.figure1,handles);


% --- Executes on button press in Select_Structure_Button.
function Select_Structure_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Structure_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.direction == 1
	planC = handles.planC1;
else
	planC = handles.planC2;
end

idxes = planC{end};
for k = 1:length(planC{idxes.structures})
	structure_names{k} = planC{idxes.structures}(k).structureName;
end

% Select the structures
prompt = 'Select the structures to deform';
[structnums,ok] = listdlg('PromptString',prompt,'ListString',structure_names);
if ok ~= 1 || isempty(structnums)
	return;
end

handles.selected_struct_nums = structnums;
guidata(handles.figure1,handles);
set(handles.Continue_Button,'enable','on');
return;

% --- Executes on button press in Continue_Button.
function Continue_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Continue_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.planC1 = [];
handles.planC2 = [];
guidata(handles.figure1,handles);
close;
uiresume;

% --- Executes on button press in Moving_Image_Plan_Button.
function Moving_Image_Plan_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Moving_Image_Plan_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.planC1 = load_a_CERR_plan('Select the CERR plan of the moving image');
guidata(handles.figure1,handles);

if ~isempty(handles.planC1)
	idxes = handles.planC1{end};
	if isempty(handles.planC1{idxes.structures})
			uiwait(msgbox('Warning: no structure in the plan'));
	else
		set(handles.Fixed_Image_Plan_Button,'enable','on');
	end
end



% --------------------------------------------------------------------
function [planC,filename,pathname] = load_a_CERR_plan(prompt)
planC = [];
[filename,pathname] = uigetfile('*.mat',prompt);
if filename == 0 
	return;
end
wholename = [pathname filename];

if ~exist(wholename,'file')
	uiwait(msgbox('File dose not exist.'));
	return;
end

load(wholename);
return;



function Smoothing_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Smoothing_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Smoothing_Input as text
%        str2double(get(hObject,'String')) returns contents of Smoothing_Input as a double

handles.smoothing = str2num(get(hObject,'string'));
guidata(handles.figure1,handles);

% --- Executes during object creation, after setting all properties.
function Smoothing_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Smoothing_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Use_Mesh_checkbox.
function Use_Mesh_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Use_Mesh_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Use_Mesh_checkbox
handles.use_mesh = get(hObject,'value');
guidata(handles.figure1,handles);



