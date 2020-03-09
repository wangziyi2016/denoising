function Paint_Image_Callback(handles)
%
%
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

ax = get(handles.gui_handles.figure1,'currentaxes');
for idx = 1:7
	if ax == handles.gui_handles.axes_handles(idx)
		break;
	end
end

imgno = handles.gui_options.display_mode(idx,2);
if imgno > 2 || handles.gui_options.display_mode(idx,1) ~= 3
	% Only for image 1 and image 2
	% Only for transverse display
	return;
end

zoom_pt = round(get(ax,'CurrentPoint'));
xin = zoom_pt(1,1);
yin = zoom_pt(1,2);

painter_size = 5;
% painter_val = 900;

% dim = mysize(handles.images(imgno).image);


displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
vecidx = WhichImageCoordinateToUse(displaymode);
vec = vecs(vecidx);

xs = vec.xs;
ys = vec.ys;
% xs = 1:dim(2);
% ys = 1:dim(1);

[xx,yy] = meshgrid(xs,ys);
dist = sqrt((xx-xin).^2+(yy-yin).^2);
mask = (dist <= painter_size);

if imgno == 1
	image_offsets = handles.reg.images_setting.image_offsets;
else
	image_offsets = [0 0 0];
end

img2d = handles.images(imgno).image(:,:,image_offsets(3) + handles.gui_options.slidervalues(1,3));
val = min(img2d(mask==1));
img2d(mask==1) = val;
handles.images(imgno).image(:,:,handles.gui_options.slidervalues(1,3)) = img2d;
handles.images(imgno).image = handles.images(imgno).image;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

