function [newimg,z0,Vy,Vx,Vz] = move3dimage2(img,Vy,Vx,Vz,method)
%
% Calculate the moved image: newimg = move3dimage2(img,Vy,Vx,Vz,method)
%
% Input: 
%	Vy, Vx, Vz	- the motion field
%	method		- interpolation method, default value is 'linear'
%
%
% In version 2, the function is able to compute extended image, that size
% could be larger than the original image before motion. Extension will be
% only in z direction.
% 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('method') | isempty(method)
	method = 'linear';
end

% Move image with extension in z direction
dim = size(img);
x0 = single([1:dim(2)]);
y0 = single([1:dim(1)]);
z0 = single([1:dim(3)]);
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

Vz2 = zz-Vz;
maxVz = ceil(max(Vz2(:)));
minVz = floor(min(Vz2(:)));
clear Vz2;

if( (minVz < 1 & (1-minVz) > dim(3) ) | maxVz > 2*dim(3) )
	warning('Motion is too large than the image dimension');
end

z0 = single(min(minVz,1):max(dim(3),maxVz));

[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels
Vx = interpn(Vx,yy,xx,zz,'spline');
Vy = interpn(Vy,yy,xx,zz,'spline');
Vz = interpn(Vz,yy,xx,zz,'spline');

Vy2 = max((yy-Vy),1); Vy2 = min(Vy2,dim(1));
Vx2 = max((xx-Vx),1); Vx2 = min(Vx2,dim(2));
Vz2 = max((zz-Vz),min(z0)); Vz2 = min(Vz2,max(z0));

if( minVz < 1 )
	img1 = 2*img(:,:,1)-img(:,:,2);
	img1 = max(img1,0); img1 = min(img1,1);
	img = cat(3,img1,img);
	Vz2 = Vz2+1;
end

if( maxVz > dim(3) )
	img1 = 2*img(:,:,end)-img(:,:,end-1);
	img1 = max(img1,0); img1 = min(img1,1);
	img = cat(3,img,img1);
end

newimg = interpn(img,Vy2,Vx2,Vz2,method);


