function im1n=impatch2(im1,n,defval)
%
% Patch the image so that the width and length of the image should the
% exact times of the number 'n'
%
% Function:		im1n = impatch2(im1,n,defval)
%
% Example:		im1n = impatch2(im1,32,0);
%
siz = size(im1);

if( mod(siz(1),n) > 0 )
	im1 = [im1;ones(n-mod(siz(1),n),siz(2))*defval];
	siz = size(im1);
end

if( mod(siz(2),n) > 0 )
	im1 = [im1 ones(siz(1),n-mod(siz(2),n))*defval];
end

im1n = im1;
