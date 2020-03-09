function handles = CLAHE_Callback(handles,preproecessing_on_images)
%
%
%
if preproecessing_on_images(1) == 1 && preproecessing_on_images(2) == 1
	dim1 = mysize(handles.images(1).image);
	dim2 = mysize(handles.images(2).image);
	setinfotext('CLAHE image #1 ...');
	handles.images(1).image = adapthisteq3d(handles.images(1).image);
	handles.images(1).image = handles.images(1).image;
	setinfotext('CLAHE image #2 ...');
	handles.images(2).image = adapthisteq3d(handles.images(2).image);
	handles.images(2).image = handles.images(2).image;
	handles = Logging(handles,'Both images CLAHE together');
elseif preproecessing_on_images(1) == 1
	setinfotext('CLAHE image #1 ...');
	handles.images(1).image = adapthisteq3d(handles.images(1).image);
	handles.images(1).image = handles.images(1).image;
	handles = Logging(handles,'Image #1 CLAHE');
elseif preproecessing_on_images(2) == 1
	setinfotext('CLAHE image #2 ...');
	handles.images(2).image = adapthisteq3d(handles.images(2).image);
	handles.images(2).image = handles.images(2).image;
	handles = Logging(handles,'Image #2 CLAHE');
end


