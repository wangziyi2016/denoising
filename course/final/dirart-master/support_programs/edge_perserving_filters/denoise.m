function varargout = denoise(varargin)
% ARTISTIC M-file for artistic.fig
%      ARTISTIC, by itself, creates a new ARTISTIC or raises the existing
%      singleton*.
%
%      H = ARTISTIC returns the handle to a new ARTISTIC or the handle to
%      the existing singleton*.
%
%      ARTISTIC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARTISTIC.M with the given input arguments.
%
%      ARTISTIC('Property','Value',...) creates a new ARTISTIC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before artistic_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to artistic_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help artistic

% Last Modified by GUIDE v2.5 14-Oct-2008 16:07:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @artistic_OpeningFcn, ...
                   'gui_OutputFcn',  @artistic_OutputFcn, ...
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


% --- Executes just before artistic is made visible.
function artistic_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to artistic (see VARARGIN)

% Choose default command line output for artistic
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes artistic wait for user response (see UIRESUME)
% uiwait(handles.figure1);

handles.sigma = 3;
handles.number = 8;
handles.q = 8;
handles.center = 0.5;
handles.width = 1;
guidata(hObject, handles);

if nargin > 3
    load_image_Callback([], varargin{1}, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = artistic_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_image.
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata)
    [FileName,PathName] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp; *.hdf; *.pbm; *.pcx; *.pgm; *.pnm; *.ppm; *.ras; *.tif; *.tiff; *.xwd; *.dcm', 'All Image Files'; ...
        '*.dcm; *.img','DICOM (*.dcm,*.img)'; ...
        '*.jpg; *.jpeg','JPEG (*.jpg, *.jpeg)'; ...
        '*.png','Portable Network Graphics (*.png)'; ...
        '*.bmp','Windows Bitmap (*.bmp)'; ...
        '*.hdf','Hierarchical Data Format (*.hdf)'; ...
        '*.pbm','Portable Bitmap (*.pbm)'; ...
        '*.pcx','Windows Paintbrush (*.pcx)'; ...
        '*.pgm','Portable Graymap (*.pgm)'; ...
        '*.pnm','Portable Anymap (*.pnm)'; ...
        '*.ppm','Portable Pixmap (*.ppm)'; ...
        '*.ras','Sun Raster (*.ras)'; ...
        '*.tif; *.tiff','Tagged Image File Format (*.tif, *.tiff)'; ...
        '*.xwd','X Windows Dump (*.xwd)'; ...
        '*', 'All Files (*.*)'}, ...
        'Load image');
    
    if FileName
        [pathstr, namestr, extstr] = fileparts(FileName);
        if strcmpi(extstr,'.dcm') == 1 || strcmpi(extstr,'.img') == 1
            % dicom image
            handles.img = double(dicomread([PathName,FileName]));
            handles.img = handles.img / max(handles.img(:));
        else
            handles.img = double(imread([PathName,FileName]))/255;
        end
    else
        return;
    end
else
    % image data is passed
    handles.img = double(eventdata);
    handles.img = handles.img / max(handles.img(:));
end

if isfield(handles,'out')
    handles = rmfield(handles,'out');
end
guidata(handles.figure1, handles);

axes(handles.image);
imshow(handles.img,[handles.center-handles.width/2,handles.center+handles.width/2]);


[nr,nc,N] = size(handles.img);

s = 700/max(nr,nc); if s > 1, s = 1;, end

h_graf = gca;
%     set(h_graf, 'Position', [161, 707-nr*s, nc*s, nr*s]);
set(h_graf, 'Visible', 'On', 'XTick', [], 'YTick', []);


h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');

h_show  = findobj('Tag', 'show_img');
set(h_show, 'Enable', 'off');


% --- Executes on button press in create.
function create_Callback(hObject, eventdata, handles)
% hObject    handle to create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filter = get(handles.Filter_Popupmenu,'value');

% set(hObject, 'Enable', 'off');

h_wait = findobj('Tag', 'wait');
set(h_wait, 'String', 'Please wait...');
drawnow;

sigma = handles.sigma;
number = handles.number;
q = handles.q;

try
switch filter
	case 1
		% Gaussian low pass filter
		handles.out = lowpass2d(handles.img, sigma);
	case 2
		handles.out = bfilter2(handles.img,sigma,[sigma 0.1]);
% 		handles.out = bfilter2(handles.img,sigma);
	case 3
		% Artistic filter
		if ndims(handles.img) == 3
			handles.out = painter(handles.img, sigma, number, q/2);
		else
			handles.out = smoothing(handles.img, [],sigma, number, q/2);
		end
	case 4
		% Bilateral and Cross-Bilateral Filter using the Bilateral Grid
		handles.out = bilateralFilter(handles.img, handles.img,0,1,sigma, 1,1);
	case 5
		% Nonlocal means filtering
		handles.out = NLmeansfilter(handles.img, sigma, number, q);
	case 6
		% Faster Kuwahara
		handles.out = FasterKuwahara(handles.img,5);
	case 7
		% Frost filter
		handles.out = frost(handles.img);
	case 8
		% Lee denoising filter
		handles.out = lee(handles.img);
	case 9
		% Symmetric nearest neighbor edge-preserving filter
		handles.out = snn(handles.img,sigma);
	case 10
		% Total variation image denoising
		handles.out = tvdenoise(handles.img,sigma,number);
	case 11
		% Denoising using Fourth Order PDE
		handles.out = fpdepyou(handles.img,sigma);
	case 12
		% Anisotropic Diffusion
		handles.out = anisodiff2D(handles.img,number,1/7,1/sigma,1);
	case 13
		% Nonlocal means denoising
		options.k = sigma;      % half size for the windows
		options.T = 0.1;		% width of the gaussian, relative to max(M(:))  (=1 here)
% 		options.max_dist = 15;  % search width, the smaller the faster the algorithm will be
		options.max_dist = number;	% search width, the smaller the faster the algorithm will be
% 		options.ndims = 30;     % number of dimension used for distance computation (PCA dim.reduc. to speed up)
		options.ndims = q;     % number of dimension used for distance computation (PCA dim.reduc. to speed up)
		options.do_patchwise = 0;
		handles.out = perform_nl_means(handles.img,options);
	case 14
		% Bayesian Least Squares - Gaussian Scale Mixture denoising
		options.sigma = sigma;	% half size for the windows
		handles.out = perform_blsgsm_denoising(handles.img,options);
end
guidata(hObject, handles);

axes(handles.image);
imshow(handles.out,[handles.center-handles.width/2,handles.center+handles.width/2]);
% imshow(handles.out,[0.3 0.7]);
% set(handles.show_img, 'String', 'Show Original Image');
set(handles.show_img,'value',2);

set(h_wait, 'String', '');


h_show  = findobj('Tag', 'show_img');
set(h_show, 'Enable', 'on');

h_save  = findobj('Tag', 'save_effect');
set(h_save, 'Enable', 'on');

catch ME
    print_lasterror(ME)
	set(h_wait,'string','Error !!!');
end
set(hObject, 'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double

handles.sigma = str2double(get(hObject,'String'));
guidata(hObject, handles);

h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');

% --- Executes during object creation, after setting all properties.
function number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function number_Callback(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number as text
%        str2double(get(hObject,'String')) returns contents of number as a double

handles.number = str2double(get(hObject,'String'));
guidata(hObject, handles);

h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');


% --- Executes during object creation, after setting all properties.
function q_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function q_Callback(hObject, eventdata, handles)
% hObject    handle to q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q as text
%        str2double(get(hObject,'String')) returns contents of q as a double

handles.q = str2double(get(hObject,'String'));
guidata(hObject, handles);

h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');

% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on button press in artistic_effect.
function artistic_effect_Callback(hObject, eventdata, handles)
% hObject    handle to artistic_effect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of artistic_effect


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in show_img.
function show_img_Callback(hObject, eventdata, handles)
% hObject    handle to show_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'img')
	return;
end

axes(handles.image);
idx = get(handles.show_img,'value');
if ~isfield(handles,'out');
	idx = 1;
end

switch idx
	case 1
		imshow(handles.img,[handles.center-handles.width/2,handles.center+handles.width/2]);
	case 2
		imshow(handles.out,[handles.center-handles.width/2,handles.center+handles.width/2]);
	case 3
		diffimg = handles.img - handles.out;
		imagesc(diffimg,[-handles.width handles.width]);
		daspect([1 1 1]);
		colorbar;
		axis off;
end

% 	if strcmp(get(hObject, 'String'), 'Show Original Image') || ~isfield(handles,'out');
% 		imshow(handles.img,[handles.center-handles.width/2,handles.center+handles.width/2]);
% 		set(handles.show_img, 'String', 'Show Filtered Image');
% 	else
% 		imshow(handles.out,[handles.center-handles.width/2,handles.center+handles.width/2]);
% 		set(handles.show_img, 'String', 'Show Original Image');
% 	end


% --- Executes on button press in save_effect.
function save_effect_Callback(hObject, eventdata, handles)
% hObject    handle to save_effect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uiputfile( ...
{'*.png','Portable Network Graphics (*.png)'; ...
 '*.bmp','Windows Bitmap (*.bmp)'; ...
 '*.hdf','Hierarchical Data Format (*.hdf)'; ...
 '*.jpg','JPEG (*.jpg)'; ...
 '*.pbm','Portable Bitmap (*.pbm)'; ...
 '*.pcx','Windows Paintbrush (*.pcx)'; ...
 '*.pgm','Portable Graymap (*.pgm)'; ...
 '*.ppm','Portable Pixmap (*.ppm)'; ...
 '*.ras','Sun Raster (*.ras)'; ...
 '*.tif','Tagged Image File Format (*.tif)'; ...
 '*.xwd','X Windows Dump (*.xwd)'}, ...
 'Save artistic effect');

if FileName
    imwrite(handles.out, [PathName,FileName]);
end



function Center_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Center_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Center_Input as text
%        str2double(get(hObject,'String')) returns contents of Center_Input as a double

handles.center = str2double(get(hObject,'String'));
guidata(hObject, handles);
h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');
show_img_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Center_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Center_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Width_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Width_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Width_Input as text
%        str2double(get(hObject,'String')) returns contents of Width_Input as a double
handles.width = str2double(get(hObject,'String'));
guidata(hObject, handles);
h_but = findobj('Tag', 'create');
set(h_but, 'Enable', 'On');
show_img_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function Width_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Width_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in Filter_Popupmenu.
function Filter_Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Filter_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Filter_Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filter_Popupmenu

filter = get(handles.Filter_Popupmenu,'value');
switch filter
	case 1
		% Gaussian low pass filter
		set(handles.helptext,'string','sigma: (=1) Gaussian window size');
	case 2
 		set(handles.helptext,'string','sigma: Gaussian window size');
	case 3
 		set(handles.helptext,'string','');
% 		handles.out = smoothing(handles.img, [],sigma, number, q/2);
	case 4
		% Bilateral and Cross-Bilateral Filter using the Bilateral Grid
		set(handles.helptext,'string',sprintf('sigma(=3): sigmaSpatial'));
% output = bilateralFilter( data, edge, ...
%                          edgeMin, edgeMax, ...
%                          sigmaSpatial, sigmaRange, ...
%                          samplingSpatial, samplingRange )
		
	case 5
		% Nonlocal means filtering
		set(handles.helptext,'string',sprintf('sigma(=3): is the radio of search window\nnumber: (=2) is radio of similarity window\nArg 3 (=2): degree of filtering'));
	case 6
		% Faster Kuwahara
		set(handles.helptext,'string',sprintf('sigma: (=5,9,13,4k+1) is the window size'));
	case 7
		% Frost filter
		set(handles.helptext,'string','No parameters');
	case 8
		% Lee denoising filter
		set(handles.helptext,'string','No parameters');
	case 9
		% Symmetric nearest neighbor edge-preserving filter
		set(handles.helptext,'string',sprintf('sigma: (=2) is the window size'));
	case 10
		% Total variation image denoising
		set(handles.helptext,'string',sprintf('sigma: (=3) is the amount of denoising\nnumber: (=10) is the number of steps'));
	case 11
		% Denoising using Fourth Order PDE
		set(handles.helptext,'string',sprintf('sigma: (=10) is the number of iterations'));
	case 12
		% Anisotropic Diffusion
		set(handles.helptext,'string',sprintf('1/sigma: (=2) is gradient modulus threshold\nnumber: (=10) is the number of iterations'));
	case 13
		% Nonlocal means denoising
		set(handles.helptext,'string',sprintf('sigma: (=3) is the half size for the windows\nnumber: (=4) is the search width\nArg 3: (=8) is the number of dimensions'));
	case 14
		% Denoising using Fourth Order PDE
		set(handles.helptext,'string',sprintf('Not working'));
end

% --- Executes during object creation, after setting all properties.
function Filter_Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter_Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function show_img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to show_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


