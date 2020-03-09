function varargout = DoseDisplayOptionsUI(varargin)
% DOSEDISPLAYOPTIONSUI M-file for DoseDisplayOptionsUI.fig
%      DOSEDISPLAYOPTIONSUI, by itself, creates a new DOSEDISPLAYOPTIONSUI or raises the existing
%      singleton*.
%
%      H = DOSEDISPLAYOPTIONSUI returns the handle to a new DOSEDISPLAYOPTIONSUI or the handle to
%      the existing singleton*.
%
%      DOSEDISPLAYOPTIONSUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOSEDISPLAYOPTIONSUI.M with the given input arguments.
%
%      DOSEDISPLAYOPTIONSUI('Property','Value',...) creates a new DOSEDISPLAYOPTIONSUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DoseDisplayOptionsUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DoseDisplayOptionsUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DoseDisplayOptionsUI

% Last Modified by GUIDE v2.5 28-Jan-2009 15:52:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DoseDisplayOptionsUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DoseDisplayOptionsUI_OutputFcn, ...
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


% --- Executes just before DoseDisplayOptionsUI is made visible.
function DoseDisplayOptionsUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DoseDisplayOptionsUI (see VARARGIN)

% Choose default command line output for DoseDisplayOptionsUI
handles.output = hObject;
handles.dose = varargin{1}.ART.dose;
handles.DoseDisplayOptions = varargin{1}.gui_options.DoseDisplayOptions;
handles.reg_handles = varargin{1};
handles.cancel = 1;
idx = handles.reg_handles.gui_options.current_axes_idx;
SetDisplayText(handles);
set(handles.dose_base_input,'string',num2str(handles.DoseDisplayOptions.base(idx)));
set(handles.Isodose_Lines_Input,'string',num2str(handles.DoseDisplayOptions.isodose_lines{idx},'%d '));
set(handles.Colorwash_Max_Input,'string',num2str(handles.DoseDisplayOptions.colorwash_max(idx)));
set(handles.Colorwash_Min_Input,'string',num2str(handles.DoseDisplayOptions.colorwash_min(idx)));
set(handles.Display_Isodose_Line_Labels_Checkbox,'value',handles.DoseDisplayOptions.display_isodose_line_label(idx));
set(handles.Label_Font_Size_Input,'string',num2str(handles.DoseDisplayOptions.display_isodose_line_label_font_size(idx)));
set(handles.Isodose_Line_Width_Input,'string',num2str(handles.DoseDisplayOptions.display_isodose_line_width(idx)));
set(handles.Colormap_Button,'string',['Color Wash Colormap = ' handles.DoseDisplayOptions.colorwash_colormap]);
set(handles.Isodose_Colormap_Button,'string',['Isodose Lines Colormap = ' handles.DoseDisplayOptions.isodose_line_colormap]);
set(handles.Transparence_Input,'string',num2str(handles.DoseDisplayOptions.transparency(idx)));
doseidx = WhichDoseToDisplay(varargin{1},idx);
if doseidx == 0
	set(handles.Display_Dose_Information_Text,'string','No dose is selected to display');
else
	dose = handles.dose{doseidx};
	set(handles.Display_Dose_Information_Text,'string',sprintf('Dose to display: %s, max = %.1f cGy',dose.Description,max(dose.image(:))));
	
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DoseDisplayOptionsUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function SetDisplayText(handles)
if handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) == 1
	set(handles.Absolute_Dose_Radiobutton,'value',1);
	set(handles.Percentage_Dose_Radiobutton,'value',0);
	set(handles.Unit_Text,'string','cGy');
	set(handles.Colorwash_Max_Text,'string','Color Wash Max Dose (cGy):');
	set(handles.Colorwash_Min_Text,'string','Color Wash Min Dose (cGy):');
else
	set(handles.Absolute_Dose_Radiobutton,'value',0);
	set(handles.Percentage_Dose_Radiobutton,'value',1);
	set(handles.Unit_Text,'string','%');
	set(handles.Colorwash_Max_Text,'string','Color Wash Max Dose (%):');
	set(handles.Colorwash_Min_Text,'string','Color Wash Min Dose (%):');
end

% --- Outputs from this function are returned to the command line.
function varargout = DoseDisplayOptionsUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Absolute_Dose_Radiobutton.
function Absolute_Dose_Radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Absolute_Dose_Radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) ~= 1
	handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) = 1;
	isoline_pct_values = str2num(get(handles.Isodose_Lines_Input,'string'));
	base_value = str2num(get(handles.dose_base_input,'string'));
	isoline_abs_values = round(base_value * isoline_pct_values / 100);
	set(handles.Isodose_Lines_Input,'string',num2str(isoline_abs_values,'%d '));
	set(hObject,'value',1);
	set(handles.Percentage_Dose_Radiobutton,'value',0);
	set(handles.Unit_Text,'string','cGy');
	colorwash_max = str2num(get(handles.Colorwash_Max_Input,'string'))*base_value/100;
	set(handles.Colorwash_Max_Input,'string',num2str(round(colorwash_max)))
	colorwash_min = str2num(get(handles.Colorwash_Min_Input,'string'))*base_value/100;
	set(handles.Colorwash_Min_Input,'string',num2str(round(colorwash_min)))
	guidata(handles.figure1,handles);
	SetDisplayText(handles);
end

% --- Executes on button press in Percentage_Dose_Radiobutton.
function Percentage_Dose_Radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Percentage_Dose_Radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) ~= 0
	handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) = 0;
	isoline_abs_values = str2num(get(handles.Isodose_Lines_Input,'string'));
	base_value = str2num(get(handles.dose_base_input,'string'));
	isoline_pct_values = round(isoline_abs_values / base_value * 100);
	set(handles.Isodose_Lines_Input,'string',num2str(isoline_pct_values,'%d '));
	set(hObject,'value',1);
	set(handles.Absolute_Dose_Radiobutton,'value',0);
	set(handles.Unit_Text,'string','%');
	colorwash_max = str2num(get(handles.Colorwash_Max_Input,'string'))/base_value*100;
	set(handles.Colorwash_Max_Input,'string',num2str(round(colorwash_max)))
	colorwash_min = str2num(get(handles.Colorwash_Min_Input,'string'))/base_value*100;
	set(handles.Colorwash_Min_Input,'string',num2str(round(colorwash_min)))
	guidata(handles.figure1,handles);
	SetDisplayText(handles);
end


function Isodose_Lines_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Isodose_Lines_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Isodose_Lines_Input as text
%        str2double(get(hObject,'String')) returns contents of Isodose_Lines_Input as a double


% --- Executes during object creation, after setting all properties.
function Isodose_Lines_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Isodose_Lines_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Isodose_Lines_Generation_Button.
function Isodose_Lines_Generation_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Isodose_Lines_Generation_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lists = {'103% to 70% with 3% steps','110% to 10% with 10% steps','110% to 50% with 5% steps'};
[sel,ok] = listdlg('liststring',lists,'selectionmode','single','ListSize',[300 100],...
	'Name','Isodose Line Generation','PromptString','Generating isoline lines using:');
if ok == 1
	values = {[103:-3:70],[110:-10:10],[110:-5:50]};
	handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) = get(handles.Absolute_Dose_Radiobutton,'value');
	base_value = str2num(get(handles.dose_base_input,'string'));
	if handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) == 1
		value = round(base_value * values{sel} / 100);
	else
		value = values{sel};
	end
	set(handles.Isodose_Lines_Input,'string',num2str(value,'%d '));
end


% --- Executes on button press in OK_Button.
function OK_Button_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cancel = 0;
idx = handles.reg_handles.gui_options.current_axes_idx;
isoline_values = str2num(get(handles.Isodose_Lines_Input,'string'));
base_value = str2double(get(handles.dose_base_input,'string'));

if handles.reg_handles.gui_options.lock_between_display == 1
	handles.DoseDisplayOptions.mode(:) = get(handles.Absolute_Dose_Radiobutton,'value');
	handles.DoseDisplayOptions.base(:) = base_value;
	for k = 1:length(handles.DoseDisplayOptions.isodose_lines)
		handles.DoseDisplayOptions.isodose_lines{k} = isoline_values;
	end
	handles.DoseDisplayOptions.colorwash_max(:) = str2double(get(handles.Colorwash_Max_Input,'string'));
	handles.DoseDisplayOptions.colorwash_min(:) = str2double(get(handles.Colorwash_Min_Input,'string'));
else
	handles.DoseDisplayOptions.mode(idx) = get(handles.Absolute_Dose_Radiobutton,'value');
	handles.DoseDisplayOptions.base(idx) = base_value;
	handles.DoseDisplayOptions.isodose_lines{idx} = isoline_values;
	handles.DoseDisplayOptions.colorwash_max(idx) = str2double(get(handles.Colorwash_Max_Input,'string'));
	handles.DoseDisplayOptions.colorwash_min(idx) = str2double(get(handles.Colorwash_Min_Input,'string'));
end


if handles.reg_handles.gui_options.lock_between_display == 1
	idxes = 1:handles.reg_handles.gui_options.num_panels;
else
	idxes = handles.reg_handles.gui_options.current_axes_idx;
end

handles.DoseDisplayOptions.display_isodose_line_label(idxes) = get(handles.Display_Isodose_Line_Labels_Checkbox,'value');
font_size = str2num(get(handles.Label_Font_Size_Input,'string'));
font_size = max(font_size,4);
font_size = min(font_size,50);
handles.DoseDisplayOptions.display_isodose_line_label_font_size(idxes) = font_size;
line_width = str2num(get(handles.Isodose_Line_Width_Input,'string'));
line_width = max(line_width,0.5);
line_width = min(line_width,20);
handles.DoseDisplayOptions.display_isodose_line_width(idxes) = line_width;
transparency = str2num(get(handles.Transparence_Input,'string'));
transparency = max(transparency,0);
transparency = min(transparency,1);
handles.DoseDisplayOptions.transparency(idxes) = transparency;

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


% --- Executes on button press in Colormap_Button.
function Colormap_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Colormap_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mapselected = SelectColormap(handles.DoseDisplayOptions.colorwash_colormap);
if ~isempty(mapselected)
	handles.DoseDisplayOptions.colorwash_colormap = mapselected;
	guidata(handles.figure1,handles);
	set(handles.Colormap_Button,'string',['Color Wash Colormap = ' handles.DoseDisplayOptions.colorwash_colormap]);
end


% ------------------------------------------------
function Set_UI_values(handles)
doseidx = WhichDoseToDisplay(handles.reg_handles);
if doseidx > 0
	dose = handles.dose{doseidx};
	desstr = sprintf('Displayed dose: [%d - %s], max dose = %d Gy',doseidx,dose.Description,max(dose.image(:)));
else
	desstr = 'No dose is selected to display, max dose = NA';
end
set(handles.Display_Dose_Information_Text,'string',desstr);

if handles.DoseDisplayOptions.mode(handles.reg_handles.gui_options.current_axes_idx) == 1
	set(handles.Absolute_Dose_Radiobutton,'value',1);
	set(handles.Percentage_Dose_Radiobutton,'value',0);
else
	set(handles.Absolute_Dose_Radiobutton,'value',0);
	set(handles.Percentage_Dose_Radiobutton,'value',1);
end

if isempty(handles.DoseDisplayOptions.isodose_lines{handles.reg_handles.gui_options.current_axes_idx})
	set(handles.Isodose_Lines_Input,'string','');
else
	set(handles.Isodose_Lines_Input,'string',num2str(handles.DoseDisplayOptions.isodose_lines{handles.reg_handles.gui_options.current_axes_idx},'%.2g '));
end

set(handles.Colormap_Button,'string',['Colormap = ' handles.DoseDisplayOptions.colorwash_colormap]);
return;



function dose_base_input_Callback(hObject, eventdata, handles)
% hObject    handle to dose_base_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dose_base_input as text
%        str2double(get(hObject,'String')) returns contents of dose_base_input as a double

val = str2num(get(hObject,'String'));
val2 = round(val);
val2 = max(val2,0);
if val ~= val2
	set(hObject,'string',num2str(val2));
end

% --- Executes during object creation, after setting all properties.
function dose_base_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dose_base_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Colorwash_Max_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Colorwash_Max_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Colorwash_Max_Input as text
%        str2double(get(hObject,'String')) returns contents of Colorwash_Max_Input as a double


% --- Executes during object creation, after setting all properties.
function Colorwash_Max_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Colorwash_Max_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Colorwash_Min_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Colorwash_Min_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Colorwash_Min_Input as text
%        str2double(get(hObject,'String')) returns contents of Colorwash_Min_Input as a double


% --- Executes during object creation, after setting all properties.
function Colorwash_Min_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Colorwash_Min_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Display_Isodose_Line_Labels_Checkbox.
function Display_Isodose_Line_Labels_Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Isodose_Line_Labels_Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Display_Isodose_Line_Labels_Checkbox



function Label_Font_Size_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Label_Font_Size_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Label_Font_Size_Input as text
%        str2double(get(hObject,'String')) returns contents of Label_Font_Size_Input as a double


% --- Executes during object creation, after setting all properties.
function Label_Font_Size_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Label_Font_Size_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Isodose_Line_Width_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Isodose_Line_Width_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Isodose_Line_Width_Input as text
%        str2double(get(hObject,'String')) returns contents of Isodose_Line_Width_Input as a double


% --- Executes during object creation, after setting all properties.
function Isodose_Line_Width_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Isodose_Line_Width_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Isodose_Colormap_Button.
function Isodose_Colormap_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Isodose_Colormap_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mapselected = SelectColormap(handles.DoseDisplayOptions.isodose_line_colormap);
if ~isempty(mapselected)
	handles.DoseDisplayOptions.isodose_line_colormap = mapselected;
	guidata(handles.figure1,handles);
	set(handles.Isodose_Colormap_Button,'string',['Isodose Lines Colormap = ' handles.DoseDisplayOptions.isodose_line_colormap]);
end



function Transparence_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Transparence_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Transparence_Input as text
%        str2double(get(hObject,'String')) returns contents of Transparence_Input as a double


% --- Executes during object creation, after setting all properties.
function Transparence_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Transparence_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


