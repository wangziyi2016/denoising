function [im1n,im2n]=impatch(im1,im2)
%
% Patch the small image so that both images become the same size
%
% Function:		[im1n,im2n] = impatch(im1,im2)
%
siz1 = size(im1);
siz2 = size(im2);

if( siz1(1) < siz2(1) )
	d1 = floor((siz2(1)-siz1(1))/2);
	d2 = siz2(1)-siz1(1) - d1;
	im1n = [zeros(d1,siz1(2));im1;zeros(d2,siz1(2))];
	im2n = im2;
elseif( siz1(1) > siz2(1) )
	d1 = floor((siz1(1)-siz2(1))/2);
	d2 = siz1(1)-siz2(1) - d1;
	im1n = im1;
	im2n = [zeros(d1,siz2(2));im2;zeros(d2,siz2(2))];
end

siz1 = size(im1n);
siz2 = size(im2n);

if( siz1(2) < siz2(2) )
	d1 = floor((siz2(2)-siz1(2))/2);
	d2 = siz2(2)-siz1(2) - d1;
	im1n = [zeros(siz1(1),d1) im1n zeros(siz1(1),d2)];
	im2n = im2;
elseif( siz1(2) > siz2(2) )
	d1 = floor((siz1(2)-siz2(2))/2);
	d2 = siz1(2)-siz2(2) - d1;
	im1n = im1
	im2n = [zeros(siz2(1),d1) im2n zeros(siz2(1),d2)];
end
