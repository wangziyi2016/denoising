function Deform_Moving_Image(handles,filter)
%
%	Deform_Moving_Image(handles,filter)
%
if ~exist('filter','var')
	filter = 'linear';
	% filter = 'cubic';
end

tvf = Compute_TVF_New(handles.reg.dvf,handles.reg.images_setting.images_alignment_points(2,:),handles.images(1),handles.reg.images_setting.images_alignment_points(1,:));
deformed_image = deform_image(handles.images(1),tvf,filter);

% resample the deformed image to the same dimension as the moving image
[xs,ys,zs]=TranslateCoordinates(handles,2,tvf.xs,tvf.ys,tvf.zs,tvf.info);
[ys0,xs0,zs0] = get_image_XYZ_vectors(handles.images(1));
[xx,yy,zz] = meshgrid(xs0,ys0,zs0);
handles.images(1).image_deformed = interp3wrapper(xs,ys,zs,single(deformed_image.image),xx,yy,zz,filter);

handles = Logging(handles,'Deformed reference image is computed');
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
setinfotext('The moving image is deformed');
