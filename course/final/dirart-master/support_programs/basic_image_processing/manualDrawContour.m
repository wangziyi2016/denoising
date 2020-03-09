function varargout = manualDrawContour(command, varargin)
%"manualDrawContour"
%    Contouring callbacks for a single axis.
%
%James Alaly 6/23/04
%
%Usage:
%   To begin: manualDrawContour('axis', hAxis);
%   To quit : manualDrawContour('quit', hAxis);
%   Get Data: manualDrawContour('getContours', hAxis);
%   preDraw : manualDrawContour('setContours', hAxis, contour);

switch command

    case 'axis'
        %Specify the handle of an axis for contouring, setup callbacks.
        hAxis = varargin{1};
        hFig  = get(hAxis, 'parent');
        setappdata(hFig, 'contourAxisHandle', hAxis);
		setappdata(hAxis, 'hContour',[]);
        setappdata(hAxis, 'contourV', {});
        noneMode(hAxis);
        oldAxisProperties = get(hAxis); %Store these to return to original state. Think about this.
        oldFigureProperties = get(hFig);

        oldBtnDown = getappdata(hAxis, 'oldBtnDown');
        if isempty(oldBtnDown)
            oldBtnDown = get(hAxis, 'buttonDownFcn');
            setappdata(hAxis, 'oldBtnDown', oldBtnDown);
        end

        set(hAxis, 'hittest', 'on');
        set(hAxis, 'buttonDownFcn', 'manualDrawContour(''btnDownInAxis'')');
        set(hFig, 'WindowButtonUpFcn', 'manualDrawContour(''btnUp'')');
        set(hFig, 'doublebuffer', 'on');

    case 'quit'
        %Removed passed axis from manualDrawContour mode.
        hAxis = varargin{1};
        hFig  = get(hAxis, 'parent');
        noneMode(hAxis);
        setappdata(hAxis, 'contourV', []);
        setappdata(hAxis, 'segment', []);
        setappdata(hAxis, 'clip', []);
        drawAll(hAxis);

        set(hAxis, 'buttonDownFcn', getappdata(hAxis, 'oldBtnDown'));
        setappdata(hAxis, 'oldBtnDown', []);
        set(hFig, 'WindowButtonUpFcn', '');
        set(hFig, 'doublebuffer', 'on');

    case 'getState'
        hAxis = varargin{1};
        varargout{1} = getappdata(hAxis);

    case 'drawMode'
        %Force draw mode.
        hAxis = varargin{1};
        drawMode(hAxis);

    case 'getContours'
        %Return all contours drawn on this axis, in axis coordinates.
        hAxis = varargin{1};
        contourV = getappdata(hAxis, 'contourV');
        varargout{1} = contourV;

    case 'btnDownInAxis'
        %The action taken depends on current state.
        hAxis = gcbo;

        %Arg, temporary tie to slice viewer! Remove later.
        try
            global stateS;
            if ~isequal(stateS.handle.CERRAxis(stateS.handle.currentAxis), hAxis)
                sliceCallBack('Focus', hAxis);
                return;
            end
        end

        hFig = get(gcbo, 'parent');
        clickType = get(hFig, 'SelectionType');
        lastClickType = getappdata(hFig, 'lastClickType');
        setappdata(hFig, 'lastClickType', clickType);
        mode = getappdata(hAxis, 'mode');

        %Setup axis for motion.
        set(hFig, 'WindowButtonMotionFcn', 'manualDrawContour(''motionInFigure'')');

        %SWITCH OVER MODES.
        if strcmpi(mode,        'DRAW')
            if strcmpi(clickType, 'normal')
                %Left click: enter drawing mode and begin new contour.
                drawingMode(hAxis);
                cP = get(hAxis, 'currentPoint');
                addPoint(hAxis, cP(1,1), cP(1,2));
                drawSegment(hAxis);
            elseif strcmpi(clickType, 'extend') | (strcmpi(clickType, 'open') & strcmpi(lastClickType, 'extend'))
            elseif strcmpi(clickType, 'alt')
            end

        elseif strcmpi(mode,    'DRAWING')
            if strcmpi(clickType, 'normal')
                %Left click: add point to contour and redraw.
                cP = get(hAxis, 'currentPoint');
                addPoint(hAxis, cP(1,1), cP(1,2));
                drawSegment(hAxis);
            elseif strcmpi(clickType, 'extend') | (strcmpi(clickType, 'open') & strcmpi(lastClickType, 'extend'))
            elseif strcmpi(clickType, 'alt')
                %Right click: close new contour and return to drawMode.
                segmentNum = length(getappdata(hAxis, 'contourV')) + 1;
                closeSegment(hAxis);
                saveSegment(hAxis, segmentNum);
				
% 				global allow_multiple_contour;
% 				if( allow_multiple_contour == 1 )
% 					ButtonName=questdlg('Draw another contour?', ...
% 						'Draw another contour', ...
% 						'Yes','No','Yes');
% 					switch ButtonName
% 						case 'Yes'
% 							drawMode(hAxis);
% 						case 'No'
% 							noneMode(hAxis);
% 							hFig = get(hAxis, 'parent');
% 							set(hAxis, 'hittest', 'off');
% 							return;
% 					end
% 				else
					noneMode(hAxis);
					hFig = get(hAxis, 'parent');
					set(hAxis, 'hittest', 'off');
					return;
% 				end
			end

        elseif strcmpi(mode,    'NONE')
        end

    case 'motionInFigure'
        %The action taken depends on current state.
        hFig        = gcbo;
        hAxis       = getappdata(hFig, 'contourAxisHandle');
        clickType   = get(hFig, 'SelectionType');
        mode        = getappdata(hAxis, 'mode');

        if strcmpi(mode,        'DRAWING')
            if strcmpi(clickType, 'normal')
                %Left click+motion: add point and redraw.
                cP = get(hAxis, 'currentPoint');
                addPoint(hAxis, cP(1,1), cP(1,2));
                drawSegment(hAxis);
            end

        elseif strcmpi(mode,    'EDITING')
            if strcmpi(clickType, 'normal')
                %Left click+motion: add point to clip and redraw.
                cP = get(hAxis, 'currentPoint');
                addClipPoint(hAxis, cP(1,1), cP(1,2));
                drawClip(hAxis);
            end
        end

    case 'btnUp'
        %The action taken depends on current state.
        hFig = gcbo;
        hAxis = getappdata(hFig, 'contourAxisHandle');
        clickType = get(hFig, 'SelectionType');
        mode = getappdata(hAxis, 'mode');

        if strcmpi(mode, 'EDITING')
            connectClip(hAxis);
            editMode(hAxis);
            toggleClips(hAxis);
            drawSegment(hAxis);
        end
        set(hFig, 'WindowButtonMotionFcn', '');

end


%MODE MANAGEMENT
function drawMode(hAxis)
%Next mouse click starts a new contour and goes to drawing mode.
contourV = getappdata(hAxis, 'contourV');
segment = getappdata(hAxis, 'segment');
setappdata(hAxis, 'segment', []);
if ~isempty(segment)
    editNum = getappdata(hAxis, 'editNum');
    contourV{editNum} = segment;
    setappdata(hAxis, 'contourV', contourV);
end
setappdata(hAxis, 'mode', 'draw');
editNum = length(contourV) + 1;
setappdata(hAxis, 'editNum', editNum);
hContour = getappdata(hAxis, 'hContour');
set(hContour, 'hittest', 'off');
drawSegment(hAxis);
drawContourV(hAxis);

function drawingMode(hAxis)
%While the button is down or for each click, points are added
%to the contour being drawn.  Right click exists drawing mode.
setappdata(hAxis, 'mode', 'drawing');
setappdata(hAxis, 'segment', []);

function noneMode(hAxis)
% 	%Set noneMode
setappdata(hAxis, 'mode', 'none');
drawContourV(hAxis);
drawSegment(hAxis);
hContour = getappdata(hAxis, 'hContour');
set(hContour, 'hittest', 'on');


%     function freezeMode(hAxis)
% 	%Freezes all callbacks, button down functions etc. Use in
% 	%conjunction with state saving and returning in order to transfer
% 	%control of axis to another routine, and to return control to this.

%CONTOURING FUNCTIONS
function addPoint(hAxis, x, y);
%Add a point to the existing segment, in axis coordinates.
segment = getappdata(hAxis, 'segment');
segment = [segment;[x y]];
setappdata(hAxis, 'segment', segment);

function closeSegment(hAxis)
%Close the current segment by linking the first and last points.
segment = getappdata(hAxis, 'segment');
if ~isempty(segment)
    firstPt = segment(1,:);
    segment = [segment;[firstPt]];
    %%% apply smoothing here  %%%
%     [Bx, By]=bezier_curves(segment(:,1), segment(:,2));
%     segment=[Bx,By];
    setappdata(hAxis, 'segment', segment);
end

function saveSegment(hAxis, segmentNum)
%Save the current segment to the contourV, and exit drawmode.
segment = getappdata(hAxis, 'segment');
if ~isempty(segment)
    contourV = getappdata(hAxis, 'contourV');
    contourV{segmentNum} = segment;
    setappdata(hAxis, 'contourV', contourV);
    setappdata(hAxis, 'segment', []);
    noneMode(hAxis);
end

function delSegment(hAxis)
%Delete the segment being edited.
setappdata(hAxis, 'segment', []);
drawAll(hAxis);

%DRAWING FUNCTIONS
function drawContourV(hAxis) %%Maybe set line hittest here?? based on mode??
%Redraw the contour associated with hAxis.
hContour = getappdata(hAxis, 'hContour');
try
    delete(hContour);
end
hContour = [];

contourV = getappdata(hAxis, 'contourV');
if ~isempty(contourV)
    for i = 1:length(contourV)
        segment = contourV{i};
        if ~isempty(segment)
            hContour = [hContour, line(segment(:,1), segment(:,2), 'color', 'blue', 'linewidth', .5, 'hittest', 'off', 'erasemode', 'normal', 'userdata', i, 'ButtonDownFcn', 'manualDrawContour(''contourClicked'')', 'parent', hAxis)];
        end
    end
    setappdata(hAxis, 'hContour', hContour);
else
    setappdata(hAxis, 'hContour', []);
end

function drawSegment(hAxis)
%Redraw the current segment associated with hAxis
hSegment = getappdata(hAxis, 'hSegment');
mode = getappdata(hAxis, 'mode');
try
    delete(hSegment);
end
hSegment = [];

segment = getappdata(hAxis, 'segment');
if ~isempty(segment) & strcmpi(mode, 'drawing')
    hSegment = line(segment(:,1), segment(:,2), 'color', 'red', 'hittest', 'off', 'erasemode', 'none', 'parent', hAxis, 'ButtonDownFcn', 'manualDrawContour(''contourClicked'')');
    setappdata(hAxis, 'hSegment', hSegment);
elseif ~isempty(segment)
    hSegment = line(segment(:,1), segment(:,2), 'color', 'red', 'hittest', 'on', 'erasemode', 'normal', 'parent', hAxis, 'ButtonDownFcn', 'manualDrawContour(''contourClicked'')');
    setappdata(hAxis, 'hSegment', hSegment);
else
    setappdata(hAxis, 'hSegment', []);
end
return

function drawAll(hAxis)
%Redraw all existing contour graphics.
drawContourV(hAxis);
drawSegment(hAxis);
return


