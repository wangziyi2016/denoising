function imgout = CropImage3Dgui(varargin)
%
% This function was adapted from the CERR function drawRegField_Rd.m
%
if ischar(varargin{1})
	command = varargin{1};
else
	command = 'init';
	if ~isstruct(varargin{1})
		img.image = varargin{1};
		img.voxelsize = [1 1 1];
		img.voxel_spacing_dir = [1 1 1];
		img.origin = [0 0 0];
	else
		img = varargin{1};
	end
end
imgout = [];

switch lower(command)
    case 'init'
        w = 900; h = 450;
        screenSize = get(0,'ScreenSize');
		
		namestr = 'Cropping the image';
		if nargin > 1
			namestr = varargin{2};
		end

        hFieldFig = figure('name', namestr , 'units', 'pixels', 'color', [0.75 0.75 0.78], ...
                                'position',[(screenSize(3)-w)/2 (screenSize(4)-h)/2 w h], ...
                                'MenuBar', 'none', 'NumberTitle', 'off', 'resize', 'off', ...
                                'Tag', 'FieldFig', 'DoubleBuffer', 'on', ...
                                'buttondownfcn', 'CropImage3Dgui(''axisclicked'');', ...
                                'DeleteFcn', 'CropImage3Dgui(''cancel'');');

        %base dataset view
        vols =  img.image;
        axes('userdata', [], 'parent', hFieldFig, 'units', 'pixels', 'Tag', 'baseTransAxes', ...
                                    'position', [10 10 w/2-20 h-20], 'color', [1 0 0], 'box', 'on', 'ydir', 'normal', ...
                                    'xTickLabel', [], 'yTickLabel', [], 'xTick', [], 'yTick', [], ...
                                    'buttondownfcn', 'CropImage3Dgui(''axisclicked'');', ...
                                    'nextplot', 'add', 'linewidth', 3);
        
        ylabel('base Transverse', 'fontsize',12, 'fontweight','b')
        %im = max(vols, [], 3);
%         im = squeeze(mean(vols, 3));
        im = squeeze(max(vols, [], 3));
        hIm = imshow(im, 'DisplayRange',[min(im(:)) max(im(:))]);
        daspect([img.voxelsize(2), img.voxelsize(1), 1]);
        set(hIm, 'Hittest', 'off');
                
        axes('userdata', [], 'parent', hFieldFig, 'units', 'pixels', 'Tag', 'baseSagAxes', ...
                                    'position', [w/2+10 10 w/2-20 h-20], 'color', [1 0 0], 'box', 'on', 'ydir', 'normal', ...
                                    'xTickLabel', [], 'yTickLabel', [], 'xTick', [], 'yTick', [], ...
                                    'buttondownfcn', '', ...
                                    'nextplot', 'add', 'linewidth', 3);
        ylabel('base Sagittal', 'fontsize',12, 'fontweight','b')
%         im = squeeze(mean(vols, 2));
        im = squeeze(max(vols, [],2));
        hIm = imshow(im', 'DisplayRange',[min(im(:)) max(im(:))]);
        daspect([img.voxelsize(3), img.voxelsize(2), 1]);
        set(hIm, 'Hittest', 'off');
        
        uicontrol(hFieldFig, 'style', 'pushbutton', 'units', 'pixel', 'position',...
                            [w-220 10 100 30],'string', 'Continue', 'callback',...
                            'CropImage3Dgui(''continue'');','tag', 'continueButton');

        uicontrol(hFieldFig, 'style', 'pushbutton', 'units', 'pixel', 'position',...
                            [w-120 10 100 30],'string', 'Cancel', 'callback',...
                            'CropImage3Dgui(''cancel'');','tag', 'cancelButton');

        uicontrol(hFieldFig, 'style', 'text', 'units', 'pixel', 'position',[10 5 w-300 32], ...
                             'ForegroundColor', [1 0 0], 'backgroundcolor', [0.75 0.75 0.78], 'fontsize', 10, ...
                             'string', 'click and draw the cropping region');
        
        uiwait;
        v1=round(getappdata(gcf, 'clipBox_baseTrans'));
        v2=round(getappdata(gcf, 'clipBox_baseSag'));

		dim = size(img.image);
		xmin = 1;
		xmax = dim(2);
		ymin = 1;
		ymax = dim(1);
		zmin = 1;
		zmax = dim(3);
		if ~isempty(v1)
			xmin = v1(1,1);
			xmax = v1(1,2);
			ymin = v1(2,1);
			ymax = v1(2,2);
		end
		
		if ~isempty(v2)
			if ~isempty(v1)
				ymin = min(ymin,v2(1,1));
				ymax = max(ymax,v2(1,2));
			else
				ymin = v2(1,1);
				ymax = v2(1,2);
			end
			zmin = v2(2,1);
			zmax = v2(2,2);
		end
		
		img.image = img.image(ymin:ymax,xmin:xmax,zmin:zmax);
		img.origin = img.origin + img.voxelsize .* img.voxel_spacing_dir .* [ymin-1 xmin-1 zmin-1];

		imgout = img;
		if ~isstruct(varargin{1})
			% array only
			imgout = img.image;
		end
		
		fprintf('Image is cropped using [%d-%d,%d-%d,%d-%d]\n\tImage size after cropping = [%s]\n',...
			ymin,ymax,xmin,xmax,zmin,zmax, num2str(size(img.image),'%d '));
		close;

    case 'continue'
       uiresume;
       
            
    case 'cancel'
       uiresume;
       
       
    case 'axisclicked'
        hFig = gcf;
        
        clicktype = get(hFig, 'selectiontype');
        curPos = get(hFig, 'currentpoint');
        if (curPos(1)>=0)&&(curPos(1)<300)&&(curPos(2)>=300)&&(curPos(2)<=600)
            axes(findobj('tag', 'baseTransAxes'));
        end
        if (curPos(1)>=300)&&(curPos(1)<=600)&&(curPos(2)>=300)&&(curPos(2)<=600)
            axes(findobj('tag', 'baseSagAxes'));
        end

        switch clicktype
            
            case 'normal'
                set(hFig, 'WindowButtonMotionFcn', 'CropImage3Dgui(''clipMotion'');', ... 
                    'WindowButtonUpFcn', 'CropImage3Dgui(''clipMotionDone'');');
                CropImage3Dgui('clipStart');
                
                return;
            case {'alt' 'extend'}
                ud = get(gca, 'userdata');
                delete(findobj('tag', 'clipBox','parent', gca));
                delete(findobj('tag', 'clipBoxT1', 'parent', gca));
                delete(findobj('tag', 'clipBoxT2', 'parent', gca));
                
                return;
        end
    
    case 'clipstart'
        hAxis = gca;
        cP = get(hAxis, 'CurrentPoint');
        delete(findobj('tag', 'clipBox', 'parent', gca));
        delete(findobj('tag', 'clipBoxT1', 'parent', gca));
        delete(findobj('tag', 'clipBoxT2', 'parent', gca));
        axesToDraw = hAxis;

        
        img = get(findobj('parent', gca, 'type', 'image'), 'cdata');
        dim = size(img);
        if (cP(1,1)>0)&&(cP(1,1)<dim(2))&&(cP(2,2)>0)&&(cP(2,2)<dim(1))
            line([cP(1,1) cP(1,1),cP(1,1) cP(1,1) cP(1,1)], [cP(2,2) cP(2,2) cP(2,2) cP(2,2) cP(2,2)], ...
                    'tag', 'clipBox', 'userdata', [], 'eraseMode', 'xor', ...
                    'parent', axesToDraw, 'marker', 's', 'markerFaceColor', 'r', 'linestyle', '-', 'color', [.8 .8 .1], ...
                    'hittest', 'off');
        end
    case 'clipmotion'
        hAxis = gca;
        allLines = findobj(gca, 'tag', 'clipBox');
        delete(findobj('tag', 'clipBoxT2', 'parent', gca));
        if isempty(allLines)
            return;
        end
        
        p0 = allLines(1);
        cP = get(hAxis, 'CurrentPoint');
        xD = get(p0, 'XData');
        yD = get(p0, 'YData');
        
        img = get(findobj('parent', gca, 'type', 'image'), 'cdata');
        dim = size(img);
        if (cP(1,1)>0)&&(cP(1,1)<dim(2))&&(cP(2,2)>0)&&(cP(2,2)<dim(1))
            set(allLines, 'XData', [xD(1), xD(1),   cP(1,1), cP(1,1), xD(1)]);
            set(allLines, 'YData', [yD(1), cP(2,2), cP(2,2), yD(1),   yD(1)]);
        end
        
        t1 = text(xD(1)+2, yD(1)-6, [num2str(ceil(xD(1))), ',' num2str(ceil(yD(1)))], 'parent', gca, 'tag', 'clipBoxT1', 'color', 'yellow', 'edgeColor', 'red');
        t2 = text(cP(1,1)+2, cP(2,2)-6, [num2str(ceil(cP(1,1))), ',' num2str(ceil(cP(2,2)))], 'parent', gca, 'tag', 'clipBoxT2', 'color', 'yellow', 'edgeColor', 'red');
        
        return;        
       
    case 'clipmotiondone'
        hFig = gcbo;
        set(hFig, 'WindowButtonMotionFcn', '', 'WindowButtonUpFcn', '');
        allLines = findobj(gca, 'tag', 'clipBox');
        view = get(gca, 'tag');
        if ~isempty(allLines)
            xdata = get(allLines, 'XData');
            ydata = get(allLines, 'YData');
            
            xMin = min(xdata);
            xMax = max(xdata);
            yMin = min(ydata);
            yMax = max(ydata);
            
            if mod(xMax-xMin+1, 2)>0, xMin = xMin + 1; end;
            if mod(yMax-yMin+1, 2)>0, yMin = yMin + 1; end;
            
            
            if strcmpi(view, 'baseTransAxes');
                setappdata(gcf, 'clipBox_baseTrans', [xMin xMax; yMin yMax]);
            end
            if strcmpi(view, 'baseSagAxes');
                setappdata(gcf, 'clipBox_baseSag', [xMin xMax; yMin yMax]);
            end
        else
            if strcmpi(view, 'baseTransAxes');
                setappdata(gcf, 'clipBox_baseTrans', []);
            end
            if strcmpi(view, 'baseSagAxes');
                setappdata(gcf, 'clipBox_baseSag', []);
            end
        end
        
        return;    
        
end 



