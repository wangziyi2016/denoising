function pass = Check_Image_Dimensions(handles,showwarning)
dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);
min2 = handles.reg.images_setting.image_current_offsets;
max2 = min2+dim2;
if any(min2<0) || any(max2>dim1)
	pass = 0;
else
	pass = 1;
end

if exist('showwarning','var') && showwarning == 1 && pass == 0
	uiwait(msgbox('Image 1 must cover image 2 entirely before registration can start. Please consider to patch image 1 and crop image 2 to meet this requirement.','Warning','warn'));
end

