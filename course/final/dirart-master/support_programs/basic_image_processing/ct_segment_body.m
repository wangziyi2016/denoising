function imbody = ct_segment_body(im,thres)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if length(size(squeeze(im))) == 3
	imbody = ct_segment_body_3d(im,thres);
	return;
end

if ~exist('thres','var') || isempty(thres)
	thres = 300;
end

im2=(im>thres);
im2 = imfill(im2,'holes');

%se = strel('disk',4);
%im2b = imclose(imopen(im2,se),se);
[maxv,maxI] = max(im(:));
[x,y]=ind2sub(size(im),maxI);

im3 = logical(1-im2);
im4 = imfill(im3,[x y]);
im4 = logical(im4-im3);

im5 = imfill(im4,[1 1]);
im5 = logical(im5-im4);	% Outside
imbody = logical(1-im5);
return;