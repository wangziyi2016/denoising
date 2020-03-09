function [im1,im2,mask] = images_2d_transform(ima,imb,scale,rot,x,y)
%
% Function: [im1,im2,mask] = images_2d_transform(ima,imb,scale,rotate_angle,x,y)
%
% Perform image 2D transformation on image #2 and then set and align both images to
% the same dimension. Created empty space are set to NaN and a mask image
% is also returned for further usage.
%
% Input:	ima		-		image #1
%			imb		-		image #2
%				Both images are assumed to be initially aligned in their
%				centers
%			scale	-		scale factor, larger than 0
%			rot		-		angle of rotation
%			x		-		horizontal pixel shift
%			y		-		vertical pixel shift
%
% Output:	im1		-		reshaped image #1
%			im2		-		reshaped image #2
%			mask	-		mask map for valid regions for both images
%
%
% Implemented by:
%		Deshan Yang, WUSTL, 05/2006
%

ima = double(ima);
imb = double(imb);

siza = size(ima);
sizb = size(imb);

if( length(siza) > 2 | length(sizb) > 2 )
	error(sprintf('Function %s only supports 2D gray level images',mfilename));
end

% Scale image #2
if( scale ~= 1 )
	scale = abs(scale);
	imb = imresize(imb,scale,'bilinear');
end

% Rotate image #2
if( rot ~= 0 )
	imb = imrotate_nan(imb,rot,'bilinear');
end

% Shift image 2 and resize both images to the same dimention
[im1,im2] = shift_expand(ima,imb,x,y);

mask = (isnan(im1) ~= 1 & isnan(im2) ~= 1);




