function varargout = DoseManager(varargin)
% DOSEMANAGER M-file for DoseManager.fig
%      DOSEMANAGER, by itself, creates a new DOSEMANAGER or raises the existing
%      singleton*.
%
%      H = DOSEMANAGER returns the handle to a new DOSEMANAGER or the handle to
%      the existing singleton*.
%
%      DOSEMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOSEMANAGER.M with the given input arguments.
%
%      DOSEMANAGER('Property','Value',...) creates a new DOSEMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DoseManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DoseManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DoseManager

% Last Modified by GUIDE v2.5 15-Jan-2009 15:46:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DoseManager_OpeningFcn, ...
                   'gui_OutputFcn',  @DoseManager_OutputFcn, ...
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


% --- Executes just before DoseManager is made visible.
function DoseManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DoseManager (see VARARGIN)

% Choose default command line output for DoseManager
handles.output = hObject;
handles.dose = varargin{1}.ART.dose;
handles.reg_handles = varargin{1};
handles.cancel = 1;
handles=FillDoseList(handles);
set(handles.Dose_List_1,'value',1);
Dose_List_1_Callback(handles.Dose_List_1, [], handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DoseManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DoseManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Dose_List_1.
function Dose_List_1_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_List_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Dose_List_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dose_List_1

cursel = get(hObject,'Value');
dosestrs = GenerateDoseDescriptionList(handles.dose);
if ~isempty(dosestrs)
	des = dosestrs{cursel};
	set(handles.Dose_Description_Text_Box,'String',handles.dose{cursel}.Description);
	set(handles.UID_Text,'String',sprintf('UID = %s',handles.dose{cursel}.UID));
	set(handles.Dose_Association_List,'value',handles.dose{cursel}.association);
	set(handles.Delete_Dose_Button,'string',sprintf('Delete [%s]',des));
	set(handles.Dose_Rescale_Button,'string',sprintf('Rescale [%s]',des));
	set(handles.Dose_Add_Button,'string','Add / Subtract');
end

% --- Executes during object creation, after setting all properties.
function Dose_List_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_List_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dose_Description_Text_Box_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Description_Text_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dose_Description_Text_Box as text
%        str2double(get(hObject,'String')) returns contents of Dose_Description_Text_Box as a double

cursel = get(handles.Dose_List_1,'Value');
newstr = get(hObject,'String');
if ~isequal(newstr,handles.dose{cursel}.Description)
	handles.dose{cursel}.Description = newstr;
	guidata(handles.figure1,handles);
	dosestrs = get(handles.Dose_List_1,'string');
	dosestrs{cursel} = sprintf('%d - %s',cursel,newstr);
	set(handles.Dose_List_1,'string',dosestrs);
	set(handles.Dose_List_2,'string',dosestrs);
end


% --- Executes during object creation, after setting all properties.
function Dose_Description_Text_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_Description_Text_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Delete_Dose_Button.
function Delete_Dose_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_Dose_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursel = get(handles.Dose_List_1,'value');
N = length(handles.dose);
if cursel <= N
	if N == 1
		handles.dose = [];
	elseif cursel == 1
		handles.dose = handles.dose(2:N);
	elseif cursel == N
		handles.dose = handles.dose(1:(end-1));
	else
		handles.dose = handles.dose([1:(cursel-1) (cursel+1):N]);
	end
	set(handles.Dose_List_1,'value',1)
	handles=FillDoseList(handles);
	guidata(handles.figure1,handles);
	Dose_List_1_Callback(handles.Dose_List_1,[],handles);
end

% --- Executes on button press in Dose_Update_Button.
function Dose_Update_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Update_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Dose_Action_Selection.
function Dose_Action_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Action_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Dose_Action_Selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dose_Action_Selection

cursel = get(hobject,'value');
set(handles.Dose_Factor_Input_1,'enable','off');
set(handles.Dose_Factor_Input_2,'enable','off');
set(handles.Dose_List_2,'enable','off');
set(handles.Dose_Add_Button,'enable','off');
if cursel > 1
	set(handles.Dose_Factor_Input_1,'enable','on');
	set(handles.Dose_Factor_Input_2,'enable','on');
	set(handles.Dose_List_2,'enable','on');
	set(handles.Dose_Add_Button,'enable','on');
end

% --- Executes during object creation, after setting all properties.
function Dose_Action_Selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_Action_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Dose_List_2.
function Dose_List_2_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_List_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Dose_List_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dose_List_2


% --- Executes during object creation, after setting all properties.
function Dose_List_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_List_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dose_Factor_Input_1_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Factor_Input_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dose_Factor_Input_1 as text
%        str2double(get(hObject,'String')) returns contents of Dose_Factor_Input_1 as a double


% --- Executes during object creation, after setting all properties.
function Dose_Factor_Input_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_Factor_Input_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dose_Factor_Input_2_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Factor_Input_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dose_Factor_Input_2 as text
%        str2double(get(hObject,'String')) returns contents of Dose_Factor_Input_2 as a double


% --- Executes during object creation, after setting all properties.
function Dose_Factor_Input_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_Factor_Input_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Dose_Add_Button.
function Dose_Add_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Add_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cursel1 = get(handles.Dose_List_1,'value');
cursel2 = get(handles.Dose_List_2,'value');
factorstr1 = get(handles.Dose_Factor_Input_1,'string');
factorstr2 = get(handles.Dose_Factor_Input_2,'string');
try
	factor1 = str2double(factorstr1);
	factor2 = str2double(factorstr2);
	newdose = handles.dose{cursel1};
	newdose.image = handles.dose{cursel1}.image * factor1 + handles.dose{cursel2}.image * factor2;
	newdose.Description = 'Dose add/subtraction result';
	N = length(handles.dose);
	handles.dose{N+1} = newdose;
	handles=FillDoseList(handles);
	guidata(handles.figure1,handles);
catch
	msgbox(lasterr);
	disp(lasterr);
end


% --- Executes on button press in Dose_Close_Button.
function Dose_Close_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Close_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cancel = 0;
guidata(handles.figure1,handles);
uiresume;

% --- Executes on button press in Dose_Close_Button.
function handles=FillDoseList(handles)

flag = 'off';
if isempty(handles.dose)
	set(handles.Dose_List_1,'enable',flag,'string','No Dose');
	set(handles.Dose_Description_Text_Box,'enable',flag,'string','');
	set(handles.Dose_Factor_Input_1,'enable',flag);
	set(handles.Dose_Rescale_Button,'enable',flag);
	set(handles.Delete_Dose_Button,'enable',flag);
else
	N = length(handles.dose);
	dosestrs = GenerateDoseDescriptionList(handles.dose);
	set(handles.Dose_List_1,'String',dosestrs);
	set(handles.Dose_List_2,'String',dosestrs);

	if N > 1
		flag = 'on';
		cursel = get(handles.Dose_List_1,'value');
		if cursel > N
			cursel = 1;
			set(handles.Dose_List_1,'value',cursel);
		end
		if cursel == 1
			set(handles.Dose_List_2,'value',2);
		else
			set(handles.Dose_List_2,'value',1);
		end
	end
end
set(handles.Dose_Factor_Input_2,'enable',flag);
set(handles.Dose_List_2,'enable',flag);
set(handles.Dose_Add_Button,'enable',flag);
return;


% --- Executes on button press in Dose_Rescale_Button.
function Dose_Rescale_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Rescale_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursel = get(handles.Dose_List_1,'value');
factorstr = get(handles.Dose_Factor_Input_1,'string');
try
	factor = str2double(factorstr);
	handles.dose{cursel}.image = handles.dose{cursel}.image * factor;
	guidata(handles.figure1,handles);
catch
	msgbox(lasterr);
	disp(lasterr);
end


% --- Executes on button press in Dose_Cancel_Button.
function Dose_Cancel_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Cancel_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.cancel = 1;
guidata(handles.figure1,handles);
uiresume;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% handles.cancel = 1;
% guidata(handles.figure1,handles);
% uiresume;
% pause(1);
delete(hObject);


% --- Executes on button press in Load_CERR_Dose_Button.
function Load_CERR_Dose_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Load_CERR_Dose_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newdose = Load_Dose_CERR;
if ~isempty(newdose)
	newdose.association = GetAssociatedImageIdx(handles.reg_handles,newdose.assocScanUID);
	if isempty(handles.dose)
		handles.dose{1} = newdose;
	else
		handles.dose{end+1} = newdose;
	end
	handles=FillDoseList(handles);
	guidata(handles.figure1, handles);
end


% --- Executes on button press in Load_Dose_DICOMRT_Button.
function Load_Dose_DICOMRT_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Dose_DICOMRT_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newdose = Load_Dose_DICOMRT;
if ~isempty(newdose)
% 	newdose = GetAssociatedImageIdx(handles.reg_handles,newdose);
	newdose.association = GetAssociatedImageIdx(handles.reg_handles,newdose.assocScanUID);
	if isempty(handles.dose)
		handles.dose{1} = newdose;
	else
		handles.dose{end+1} = newdose;
	end
	handles=FillDoseList(handles);
	guidata(handles.figure1, handles);
end


% --- Executes on selection change in Dose_Association_List.
function Dose_Association_List_Callback(hObject, eventdata, handles)
% hObject    handle to Dose_Association_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Dose_Association_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dose_Association_List

cursel = get(handles.Dose_List_1,'value');
% answer = questdlg('Are you sure to change the association from image to dose','Warning','Yes','No','No');
% if strcmpi(answer,'Yes')
	sel=get(hObject,'value');
	handles.dose{cursel}.association = sel;
	guidata(handles.figure1,handles);
% else
% 	set(hObject,'value',handles.dose{cursel}.association);
% end


% --- Executes during object creation, after setting all properties.
function Dose_Association_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dose_Association_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

	
