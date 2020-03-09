function [res, im1, im2, mask] = images_info_transform(im1, im2, type,scale,ang, x, y)
%
% Function res = calc_images(im1, im2, type, scale, ang, x, y)
% 
% Compututation for two 2D images
%
%	Input:
%			im1		-	image 1
%			im2		-	image 2
%					Both images are assumed to be aligned at their centers
%					since they could be in different size
%
%			type = 1:	to calculate mutual information
%			type = 2:	to calculate crosscorelation
%			type = 3:	to calculate the joint histogram
%
%			scale	-	the zoom factor
%			ang		-	rotate angle (counterclockwise) for image 2
%			x		-	horizontal shift of image 2 in pixel
%			y		-	vertical shift of image 2 in pixel
%					Both x and y could be either position or negative
%
%  implemented by:
%		Deshan Yang
%		Washington University in St Louis
%		05/2006
%

siz1 = size(im1);
siz2 = size(im2);

if( length(siz1) > 2 | length(siz2) > 2 )
	warning(sprintf('Function %s only supports 2D gray level images',mfilename));
	im1 = mean(im1,3);
	im2 = mean(im2,3);
end

% Normalize the intensity for both images
im1 = double(im1);
im2 = double(im2);

m = max(max(im1(:)),max(im2(:)));
im1 = im1 / m * 255;
im2 = im2 / m * 255;

% Transform image #2
[im1,im2,mask] = images_2d_transform(im1,im2,scale,ang,x,y);

if( sum(mask(:)) == 0 )
	warning('Images are totally misaligned');
	if( type == 3 )
		res = zeros(256,256);
	else
		res = 0;
	end
	
	return;
end

% Ready to perform calculation

switch( type )
	case 1
		% Calculate the jointed histogram

		jhist = joint_hist(im1,im2,256,mask);

		jhist_log = zeros(256*256,1);
		idx_good = find(jhist~=0);
		jhist_log(idx_good) = log(jhist(idx_good));
		HAB = -sum(jhist_log(idx_good).*jhist(idx_good));
		
 		HA = entropy_nan(im1,mask);
 		HB = entropy_nan(im2,mask);
		
		res = (HA+HB)/HAB;		% The mutual information
		
	case 2
		% Calculate the cross-correlation
		good_idx = find(mask==1);
		meana = mean(im1(good_idx));
		meanb = mean(im2(good_idx));
		
		res = sum(sum((im1(good_idx)-meana).*(im2(good_idx)-meanb))) / sqrt( sum(sum((im1(good_idx)-meana).^2)) * sum(sum((im2(good_idx)-meanb).^2)));
	case 3
		res = joint_hist(im1,im2,256,mask);
	otherwise
		error(sprintf('Type = %d is not supported',type));
end





