function handles = Histogram_Equalization_Callback(handles,preproecessing_on_images)
%
%
%
if preproecessing_on_images(1) == 1 && preproecessing_on_images(2) == 1
	dim1 = mysize(handles.images(1).image);
	dim2 = mysize(handles.images(2).image);
	setinfotext('Histogram EQ image #1 ...');
	dummy = histeq([handles.images(1).image(:);handles.images(2).image(:)],1024);
	handles.images(1).image = reshape(dummy(1:prod(dim1)),dim1);
	handles.images(2).image = reshape(dummy(prod(dim1)+1:end),dim2);
	handles = Logging(handles,'Both images are histogram equalized together');
elseif preproecessing_on_images(1) == 1
	dim = mysize(handles.images(1).image);
	setinfotext('Histogram EQ image #1 ...');
	handles.images(1).image = histeq(handles.images(1).image(:),1024);
	handles.images(1).image = reshape(handles.images(1).image,dim);
	handles = Logging(handles,'Image #1 is histogram equalized');
elseif preproecessing_on_images(2) == 1
	dim = mysize(handles.images(2).image);
	setinfotext('Histogram EQ image #2 ...');
	handles.images(2).image = histeq(handles.images(2).image(:),1024);
	handles.images(2).image = reshape(handles.images(2).image,dim);
	handles = Logging(handles,'Image #2 is histogram equalized');
end



