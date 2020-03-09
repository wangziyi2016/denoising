function varargout = StructureManager(varargin)
% STRUCTUREMANAGER M-file for StructureManager.fig
%      STRUCTUREMANAGER, by itself, creates a new STRUCTUREMANAGER or raises the existing
%      singleton*.
%
%      H = STRUCTUREMANAGER returns the handle to a new STRUCTUREMANAGER or the handle to
%      the existing singleton*.
%
%      STRUCTUREMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRUCTUREMANAGER.M with the given input arguments.
%
%      STRUCTUREMANAGER('Property','Value',...) creates a new STRUCTUREMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StructureManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StructureManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StructureManager

% Last Modified by GUIDE v2.5 19-Feb-2009 10:57:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StructureManager_OpeningFcn, ...
                   'gui_OutputFcn',  @StructureManager_OutputFcn, ...
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


% --- Executes just before StructureManager is made visible.
function StructureManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StructureManager (see VARARGIN)

% Choose default command line output for StructureManager
handles.output = hObject;
handles.cancel = 1;
handles.reg_handles = varargin{1};
handles.images = handles.reg_handles.images;
handles.ART = handles.reg_handles.ART;
set(handles.Structure_List,'string',PrefixStructureNames(handles));
% Update handles structure
guidata(hObject, handles);
Structure_List_Callback(handles.Structure_List, eventdata, handles);

% UIWAIT makes StructureManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StructureManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_Button.
function Load_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[structs,assocScanIDs,scanInfos] = ART_Load_Structure_CERR;
if ~isempty(structs)
	handles = AddNewStructures(handles,structs,assocScanIDs,scanInfos);
	guidata(handles.figure1,handles);
	setinfotext('Structures are loaded from a CERR plan');
	% Update handles structure
	guidata(hObject, handles);
	set(handles.Structure_List,'string',PrefixStructureNames(handles));
	Structure_List_Callback(handles.Structure_List, eventdata, handles);
end


% --- Executes on button press in Close_Button.
function Close_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Close_Button (see GCBO)
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
uiresume;


% --- Executes on selection change in Structure_List.
function Structure_List_Callback(hObject, eventdata, handles)
% hObject    handle to Structure_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Structure_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Structure_List
if ~isempty(handles.ART.structures)
	strnum = get(hObject,'value');
	infostr = GetStructInformation(handles,strnum);
	set(handles.Information_Text,'string',infostr);
	set(handles.Information_Text,'BackgroundColor',handles.ART.structure_colors(strnum,:),'ForegroundColor',GetForegroundColor(handles.ART.structure_colors(strnum,:)));
	set(handles.Color_Box,'BackgroundColor',handles.ART.structure_colors(strnum,:));
	set(handles.Display_checkbox,'value',handles.ART.structure_display(strnum));
end

% --- Executes during object creation, after setting all properties.
function infostr = GetStructInformation(handles,strnum)
strdata = GetElement(handles.ART.structures,strnum);
if handles.ART.structure_assocImgIdxes(strnum) == 1
	infostr = ' - Associated with the moving image';
else
	infostr = ' - Associated with the fixed image';
end
if strdata.meshRep == 1
	infostr = [num2str(strnum) infostr sprintf('\n%d slices',handles.ART.structure_structInfos{strnum}.numslices)];
else
	infostr = [num2str(strnum) infostr sprintf('\nis a POI')];
end


% --- Executes during object creation, after setting all properties.
function Structure_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Structure_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Delete_Button.
function Delete_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
N = length(handles.ART.structures);
if N == 1
	handles.ART.structures = [];
	handles.ART.structure_colors = [];
	handles.ART.structure_display = [];
	handles.ART.structure_names = cell(0);
	handles.ART.structure_assocScanIDs = [];
	handles.ART.structure_scanInfos = [];
	handles.ART.structure_structInfos = [];
	handles.ART.structure_assocImgIdxes = [];
else
	if strnum == 1
		idxes = 2:N;
	elseif strnum == N
		idxes = 1:(N-1);
		strnum = N-1;
	else
		idxes = [1:(strnum-1) (strnum+1):N];
		strnum = strnum-1;
	end

	handles.ART.structures = handles.ART.structures(idxes);
	handles.ART.structure_colors = handles.ART.structure_colors(idxes,:);
	handles.ART.structure_display = handles.ART.structure_display(idxes);
	handles.ART.structure_names = handles.ART.structure_names(idxes);
	handles.ART.structure_assocScanIDs = handles.ART.structure_assocScanIDs(idxes);
	handles.ART.structure_structInfos = handles.ART.structure_structInfos(idxes);
	handles.ART.structure_assocImgIdxes = handles.ART.structure_assocImgIdxes(idxes);
end

set(handles.Structure_List,'string',PrefixStructureNames(handles));
if ~isempty(handles.ART.structures)
	set(handles.Structure_List,'value',strnum);
end
guidata(handles.figure1,handles);


% --- Executes on button press in Color_Button.
function Color_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Color_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
newcolor=uisetcolor(handles.ART.structure_colors(strnum,:));
if ~isequal(newcolor,handles.ART.structure_colors(strnum,:))
	handles.ART.structure_colors(strnum,:) = newcolor;
	guidata(handles.figure1,handles);
	set(handles.Information_Text,'BackgroundColor',handles.ART.structure_colors(strnum,:),'ForegroundColor',GetForegroundColor(handles.ART.structure_colors(strnum,:)));
	set(handles.Color_Box,'BackgroundColor',handles.ART.structure_colors(strnum,:));
end


% --- Executes on button press in Information_Button.
function fc = GetForegroundColor(color)
if sum(color) > 1.5
	fc = [0 0 0];
else
	fc = [1 1 1];
end

% --- Executes on button press in Information_Button.
function Information_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Information_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
strdata = GetElement(handles.ART.structures,strnum);
if strdata.meshRep == 0
	volume = 0;
else
	[mask3d,yVals,xVals,zVals] = MakeStructureMask(strdata,[],2);
	dx = abs(xVals(2)-xVals(1));	% in mm
	dy = abs(yVals(2)-yVals(1));
	dz = abs(zVals(2)-zVals(1));
	volume = sum(mask3d(:)) * dx * dy * dz / 1000;	% in cm3
end
msgbox(sprintf('Volume = %.2f cm3',volume),'Structure Information','modal');


% --- Executes on button press in Display_checkbox.
function Display_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Display_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Display_checkbox
strnum = get(handles.Structure_List,'value');
handles.ART.structure_display(strnum) = 1-handles.ART.structure_display(strnum);
set(hObject,'value',handles.ART.structure_display(strnum));
guidata(handles.figure1,handles);


% --- Executes on button press in HideAll_pushbutton.
function HideAll_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HideAll_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ART.structure_display = zeros(1,length(handles.ART.structures));
set(handles.Display_checkbox,'value',0);
guidata(handles.figure1,handles);


% --- Executes on button press in Display_All_pushbutton.
function Display_All_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Display_All_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ART.structure_display = ones(1,length(handles.ART.structures));
set(handles.Display_checkbox,'value',1);
guidata(handles.figure1,handles);


% --------------------------------------------------------------------
function Color_Box_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Color_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Color_Button_Callback(hObject, eventdata, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over color_text.
function color_text_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to color_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Color_Button_Callback(hObject, eventdata, handles);


% --- Executes on button press in Reset_Color_pushbutton.
function Reset_Color_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Color_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

N = length(handles.ART.structures);
if N > 0
	handles.ART.structure_colors = lines(N);
	guidata(handles.figure1,handles);
	Structure_List_Callback(handles.Structure_List, [], handles);
end

% --- Executes on button press in Rename_Button.
function Rename_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Rename_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
options.Resize = 'on';
options.WindowStyle = 'modal';
answer = inputdlg('Enter new names for this structure','Rename',1,{handles.ART.structure_names{strnum}},options);
if ~isempty(answer)
	newname = answer{1};
	if strcmp(newname,handles.ART.structure_names{strnum}) ~= 1
		handles.ART.structure_names{strnum} = newname;
		handles.ART.structures{strnum}.structureName = newname;
		guidata(handles.figure1,handles);
		set(handles.Structure_List,'string',PrefixStructureNames(handles));
	end
end


% --- Executes on button press in Smooth_Button.
function Smooth_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
struct1 = GetElement(handles.ART.structures,strnum);
imgidx = handles.ART.structure_assocImgIdxes(strnum);
img = handles.reg_handles.images(imgidx);
newStruct = SmoothStructure(struct1,img);
if isempty(newStruct)
	return;
end

newStructs{1} = newStruct;
handles = AddNewStructures(handles,newStructs,handles.ART.structure_assocScanIDs(strnum));
handles.ART.structure_assocImgIdxes(end) = imgidx;
guidata(handles.figure1,handles);
set(handles.Structure_List,'string',PrefixStructureNames(handles));


% --- Executes on button press in Contract_Button.
function Contract_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Contract_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
struct1 = GetElement(handles.ART.structures,strnum);
imgidx = handles.ART.structure_assocImgIdxes(strnum);
img = handles.reg_handles.images(imgidx);
newStruct = ExpandContractStructure(struct1,img,2);
if isempty(newStruct)
	return;
end

newStructs{1} = newStruct;
handles = AddNewStructures(handles,newStructs,handles.ART.structure_assocScanIDs(strnum));
handles.ART.structure_assocImgIdxes(end) = imgidx;

guidata(handles.figure1,handles);
set(handles.Structure_List,'string',PrefixStructureNames(handles));


% --- Executes on button press in Expand_Button.
function Expand_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Expand_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strnum = get(handles.Structure_List,'value');
struct1 = GetElement(handles.ART.structures,strnum);
imgidx = handles.ART.structure_assocImgIdxes(strnum);
img = handles.reg_handles.images(imgidx);
newStruct = ExpandContractStructure(struct1,img,1);
if isempty(newStruct)
	return;
end

newStructs{1} = newStruct;
handles = AddNewStructures(handles,newStructs,handles.ART.structure_assocScanIDs(strnum));
handles.ART.structure_assocImgIdxes(end) = imgidx;

guidata(handles.figure1,handles);
set(handles.Structure_List,'string',PrefixStructureNames(handles));


% --- Executes on button press in CleanUpButton.
function CleanUpButton_Callback(hObject, eventdata, handles)
% hObject    handle to CleanUpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CopyToButton.
function CopyToButton_Callback(hObject, eventdata, handles)
% hObject    handle to CopyToButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strnum = get(handles.Structure_List,'value');
newStruct = CopyStructure2OtherImage(handles.reg_handles,GetElement(handles.ART.structures,strnum),handles.ART.structure_assocImgIdxes(strnum));
newStruct.structureName = [handles.ART.structure_names{strnum} '_copied'];

newStructs{1} = newStruct;

handles = AddNewStructures(handles,newStructs,handles.ART.structure_assocScanIDs(strnum));	% the assocScanID is not correct, but does not matter
handles.ART.structure_assocImgIdxes(end) = 3-handles.ART.structure_assocImgIdxes(end);
guidata(handles.figure1,handles);
set(handles.Structure_List,'string',PrefixStructureNames(handles));




