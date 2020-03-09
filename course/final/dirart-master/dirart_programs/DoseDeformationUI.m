function varargout = DoseDeformationUI(varargin)
% DOSEDEFORMATIONUI M-file for DoseDeformationUI.fig
%      DOSEDEFORMATIONUI, by itself, creates a new DOSEDEFORMATIONUI or raises the existing
%      singleton*.
%
%      H = DOSEDEFORMATIONUI returns the handle to a new DOSEDEFORMATIONUI or the handle to
%      the existing singleton*.
%
%      DOSEDEFORMATIONUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOSEDEFORMATIONUI.M with the given input arguments.
%
%      DOSEDEFORMATIONUI('Property','Value',...) creates a new DOSEDEFORMATIONUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DoseDeformationUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DoseDeformationUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DoseDeformationUI

% Last Modified by GUIDE v2.5 16-Jan-2009 11:40:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DoseDeformationUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DoseDeformationUI_OutputFcn, ...
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


% --- Executes just before DoseDeformationUI is made visible.
function DoseDeformationUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DoseDeformationUI (see VARARGIN)

% Choose default command line output for DoseDeformationUI
handles.output = hObject;
handles.cancel = 1;
h = varargin{1};
handles.dose = h.ART.dose;
if isempty(h.reg.idvf.x)
	handles.has_IDVF = 0;
else
	handles.has_IDVF = 1;
end
if isempty(h.reg.dvf.x)
	handles.has_DVF = 0;
else
	handles.has_DVF = 1;
end

dosestrs = GenerateDoseDescriptionList(handles.dose);
set(handles.Dose_List,'string',dosestrs);
set(handles.Dose_List,'value',1);
guidata(hObject, handles);
Dose_List_Callback(handles.Dose_List, [], handles);

% Update handles structure

% UIWAIT makes DoseDeformationUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DoseDeformationUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Dose_List.
function Dose_List_Callback(hObject, eventdata, handles)
cursel = get(hObject,'value');
dose = handles.dose{cursel};
set(handles.Image_List,'value',3-dose.association);
newdes = get(handles.New_Dose_Description_Input,'string');
if isempty(newdes)
	set(handles.New_Dose_Description_Input,'string',sprintf('Deformed dose - %s',dose.Description));
end

set(handles.Deform_Dose_Button,'enable','on');
set(handles.Image_List,'enable','on');
set(handles.Dose_Description_Text,'ForegroundColor',[0 0 0]);
if dose.association == 1
	des = 'Associated with the moving image';
	if handles.has_DVF == 0
		des = sprintf('%d\nCannot deform this dose because DVF is not computed',des);
		set(handles.Deform_Dose_Button,'enable','off');
		set(handles.Image_List,'enable','off');
		set(handles.Dose_Description_Text,'ForegroundColor',[1 0 0]);
	end
else
	des = 'Associated with the fixed image';
	if handles.has_IDVF == 0
		des = sprintf('%s\nCannot deform this dose because the inverse DVF is not computed',des);
		set(handles.Deform_Dose_Button,'enable','off');
		set(handles.Image_List,'enable','off');
		set(handles.Dose_Description_Text,'ForegroundColor',[1 0 0]);
	end
end
set(handles.Dose_Description_Text,'string',des);

% --- Executes during object creation, after setting all properties.
function Dose_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Deform_Dose_Button.
function Deform_Dose_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Deform_Dose_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cancel = 0;
guidata(handles.figure1,handles);
uiresume;

% --- Executes on button press in Cancel_Button.
function Cancel_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cancel = 1;
guidata(handles.figure1,handles);
uiresume;


function New_Dose_Description_Input_Callback(hObject, eventdata, handles)
% hObject    handle to New_Dose_Description_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of New_Dose_Description_Input as text
%        str2double(get(hObject,'String')) returns contents of New_Dose_Description_Input as a double


% --- Executes during object creation, after setting all properties.
function New_Dose_Description_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to New_Dose_Description_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Image_List.
function Image_List_Callback(hObject, eventdata, handles)
% hObject    handle to Image_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Image_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Image_List


% --- Executes during object creation, after setting all properties.
function Image_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


