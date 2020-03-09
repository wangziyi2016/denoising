function varargout = StructureColorListUI(varargin)
% STRUCTURECOLORLISTUI M-file for StructureColorListUI.fig
%      STRUCTURECOLORLISTUI, by itself, creates a new STRUCTURECOLORLISTUI or raises the existing
%      singleton*.
%
%      H = STRUCTURECOLORLISTUI returns the handle to a new STRUCTURECOLORLISTUI or the handle to
%      the existing singleton*.
%
%      STRUCTURECOLORLISTUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRUCTURECOLORLISTUI.M with the given input arguments.
%
%      STRUCTURECOLORLISTUI('Property','Value',...) creates a new STRUCTURECOLORLISTUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StructureColorListUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StructureColorListUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StructureColorListUI

% Last Modified by GUIDE v2.5 16-Feb-2009 20:55:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StructureColorListUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StructureColorListUI_OutputFcn, ...
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


% --- Executes just before StructureColorListUI is made visible.
function StructureColorListUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StructureColorListUI (see VARARGIN)

% Choose default command line output for StructureColorListUI
handles.output = hObject;
handles.main_figure = varargin{1}.gui_handles.figure1;
handles.colors = varargin{1}.ART.structure_colors;
handles.ART = varargin{1}.ART;
handles.names = PrefixStructureNames(handles);
handles.display = varargin{1}.ART.structure_display;
handles.current_page = 1;

% Update handles structure
guidata(hObject, handles);
refresh_list(handles);

% UIWAIT makes StructureColorListUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StructureColorListUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipanel1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,1);

% --------------------------------------------------------------------
function uipanel2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,2);

% --------------------------------------------------------------------
function uipanel3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,3);

% --------------------------------------------------------------------
function uipanel4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,4);

% --------------------------------------------------------------------
function uipanel5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,5);

% --------------------------------------------------------------------
function uipanel6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,6);

% --------------------------------------------------------------------
function uipanel7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,7);

% --------------------------------------------------------------------
function uipanel8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,8);

% --------------------------------------------------------------------
function uipanel9_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,9);

% --------------------------------------------------------------------
function uipanel10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,10);

% --------------------------------------------------------------------
function uipanel11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,11);

% --------------------------------------------------------------------
function uipanel12_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,12);

% --------------------------------------------------------------------
function uipanel13_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,13);

% --------------------------------------------------------------------
function uipanel14_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,14);

% --------------------------------------------------------------------
function uipanel15_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,15);

% --------------------------------------------------------------------
function uipanel16_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,16);

% --------------------------------------------------------------------
function uipanel17_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,17);

% --------------------------------------------------------------------
function uipanel18_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,18);

% --------------------------------------------------------------------
function uipanel19_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,19);

% --------------------------------------------------------------------
function uipanel20_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
panel_callback(handles,20);

% --- Executes on button press in Last_Button.
function Last_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Last_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_page > 1
	handles.current_page = handles.current_page - 1;
	guidata(handles.figure1,handles);
	refresh_list(handles);
end


% --- Executes on button press in Next_Button.
function Next_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Next_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = length(handles.names);
Npage = ceil(N/20);
if handles.current_page < Npage
	handles.current_page = handles.current_page + 1;
	guidata(handles.figure1,handles);
	refresh_list(handles);
end


% --- Executes on button press in Close_Button.
function Close_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Close_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on button press in Close_Button.
function  panel_callback(handles,idx)
maindata = guidata(handles.main_figure);
if ~isequal(maindata.ART.structure_colors,handles.colors) ||  ~isequal(PrefixStructureNames(maindata),handles.names)
	handles.colors = maindata.ART.structure_colors;
	handles.names = PrefixStructureNames(maindata);
	guidata(handles.figure1,handles);
	refresh_list(handles);
end

strnum = (handles.current_page-1)*20 + idx;
newcolor=uisetcolor(handles.colors(strnum,:));
if ~isequal(newcolor,handles.colors(strnum,:))
	handles.colors(strnum,:) = newcolor;
	guidata(handles.figure1,handles);
	figure(handles.figure1);
	refresh_list(handles);
	maindata.ART.structure_colors = handles.colors;
	guidata(maindata.gui_handles.figure1,maindata);
	RefreshDisplay(maindata);
end


return;

function refresh_list(handles)
N = length(handles.names);
Npage = ceil(N/20);
if handles.current_page > 1
	set(handles.Last_Button,'enable','on');
else
	set(handles.Last_Button,'enable','off');
end
if handles.current_page < Npage
	set(handles.Next_Button,'enable','on');
else
	set(handles.Next_Button,'enable','off');
end

for k = 1:20
	strnum = k + (handles.current_page-1)*20;
	panelh = findobj(handles.figure1,'tag',['uipanel' num2str(k)]);
	texth = findobj(handles.figure1,'tag',['text' num2str(k)]);
	if strnum > N
		set([panelh texth],'visible','off');
	else
		set([panelh texth],'visible','on');
		set(texth,'string',handles.names{strnum});
		set(panelh,'BackgroundColor',handles.colors(strnum,:));
		set(texth,'value',handles.display(strnum));
	end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text1.
function text1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = 0;


% --- Executes on button press in text1.
function text1_Callback(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text1
text_callback(handles,hObject,1);

% --- Executes on button press in text2.
function text2_Callback(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text2
text_callback(handles,hObject,2);

% --- Executes on button press in text3.
function text3_Callback(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text3
text_callback(handles,hObject,3);

% --- Executes on button press in text4.
function text4_Callback(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text4
text_callback(handles,hObject,4);


% --- Executes on button press in text5.
function text5_Callback(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text5
text_callback(handles,hObject,5);


% --- Executes on button press in text6.
function text6_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text6
text_callback(handles,hObject,6);


% --- Executes on button press in text7.
function text7_Callback(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text7
text_callback(handles,hObject,7);


% --- Executes on button press in text8.
function text8_Callback(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text8
text_callback(handles,hObject,8);


% --- Executes on button press in text9.
function text9_Callback(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text9
text_callback(handles,hObject,9);


% --- Executes on button press in text10.
function text10_Callback(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text10
text_callback(handles,hObject,10);


% --- Executes on button press in text11.
function text11_Callback(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text11
text_callback(handles,hObject,11);


% --- Executes on button press in text12.
function text12_Callback(hObject, eventdata, handles)
% hObject    handle to text12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text12
text_callback(handles,hObject,12);


% --- Executes on button press in text13.
function text13_Callback(hObject, eventdata, handles)
% hObject    handle to text13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text13
text_callback(handles,hObject,13);


% --- Executes on button press in text14.
function text14_Callback(hObject, eventdata, handles)
% hObject    handle to text14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text14
text_callback(handles,hObject,14);


% --- Executes on button press in text15.
function text15_Callback(hObject, eventdata, handles)
% hObject    handle to text15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text15
text_callback(handles,hObject,15);


% --- Executes on button press in text16.
function text16_Callback(hObject, eventdata, handles)
% hObject    handle to text16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text16
text_callback(handles,hObject,16);


% --- Executes on button press in text17.
function text17_Callback(hObject, eventdata, handles)
% hObject    handle to text17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text17
text_callback(handles,hObject,17);


% --- Executes on button press in text18.
function text18_Callback(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text18
text_callback(handles,hObject,18);


% --- Executes on button press in text19.
function text19_Callback(hObject, eventdata, handles)
% hObject    handle to text19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text19
text_callback(handles,hObject,19);


% --- Executes on button press in text20.
function text20_Callback(hObject, eventdata, handles)
% hObject    handle to text20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of text20
text_callback(handles,hObject,20);

% --- Executes on button press in text20.
function text_callback(handles,hObject,idx)
maindata = guidata(handles.main_figure);
if ~isequal(maindata.ART.structure_colors,handles.colors) ||  ~isequal(PrefixStructureNames(maindata),handles.names)
	handles.colors = maindata.ART.structure_colors;
	handles.names = PrefixStructureNames(maindata);
	guidata(handles.figure1,handles);
	refresh_list(handles);
end

strnum = (handles.current_page-1)*20 + idx;
val = get(hObject,'value');
if handles.display(strnum) ~= val
	handles.display(strnum) = 1 - handles.display(strnum);
	guidata(handles.figure1,handles);
	maindata.ART.structure_display = handles.display;
	guidata(maindata.gui_handles.figure1,maindata);
	RefreshDisplay(maindata);
end

