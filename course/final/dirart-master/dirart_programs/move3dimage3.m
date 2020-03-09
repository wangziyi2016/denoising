function newimg = move3dimage3(img,Vy,Vx,Vz,method,offsets)
%
% Calculate the moved image: 
%    newimg = move3dimage3(img,Vy,Vx,Vz,method,offsets)
%
% Input: 
%	Vy, Vx, Vz	- the motion field
%	method		- interpolation method, default value is 'linear'
%   zoffset		- Offset of Z for the motion field dimension respective to
%				  the img dimension
%
% In version 3, the input image is allowed to be larger than the dimension
% of motion fields. This actually allows better recostruction of the moved
% images because the motion fields could extend larger than the original
% dimension. An additional parameter has been added, the 'offsets'
% parameter.
% 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('method','var') || isempty(method)
	method = 'linear';
end

if ~exist('offsets','var') || isempty(offsets)
	offsets = [0 0 0];
elseif length(offsets) == 1
	offsets = [0 0 offsets];
end

dimimg = size(img);
dimmotion = size(Vy);
x0 = single(1:dimmotion(2))+offsets(1);
y0 = single(1:dimmotion(1))+offsets(2);
z0 = single(1:dimmotion(3))+offsets(3);
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

Vy = max((yy-Vy),1); Vy = min(Vy,dimimg(1));
Vx = max((xx-Vx),1); Vx = min(Vx,dimimg(2));
Vz = max((zz-Vz),1); Vz = min(Vz,dimimg(3));
newimg = interpn(img,Vy,Vx,Vz,method,0);

%newimg = interpn(img,yy-Vy,xx-Vx,zz-Vz,method,0);


