function imlung = ct_segment_lung_3d(im,thres,boundary)
%
% imlung = ct_segment_body_3d(im,thres=300,boundary=2)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if nargin == 0
	disp('Usage:');
	disp('imlung = ct_segment_lung_3d(im,thres=300,boundary=2)');
	return;
end

if ~exist('thres','var') || isempty(thres)
	thres = 300;
end
if ~exist('boundary','var') || isempty(boundary)
	boundary = 2;
end

im2=(im>thres);
dim = size(im);

se = strel('disk',3);
im3 = imopen(im2,se);

%ims = lowpass3d(single(im),2);
[maxv,maxI] = max(im(:));
[x,y,z]=ind2sub(size(im),maxI);

im3 = logical(1-im2);
im4 = imfill(im3,[x y z]);
im4 = logical(im4-im3);

im5 = imfill(im4,[1 1 1]);
im5 = logical(im5-im4);	% Outside

imlung = logical(1-(im5|im4));

se = strel('disk',boundary);
imlung = imdilate(imlung,se);

return;

