function imbody = segment_body(im,thres)

if ~exist('thres','var') || isempty(thres)
	thres = 300;
end

if length(size(squeeze(im))) == 3
	imbody = ct_segment_body_3d(im,thres);
	return;
end

im2=(im>thres);

se = strel('disk',20);
im2b = imopen(im2,se);
[maxv,maxI] = max(im2b(:));
[x,y]=ind2sub(size(im),maxI);

im3 = logical(1-im2);
im4 = imfill(im3,[x y]);
im4 = logical(im4-im3);

dim = size(im);
im5 = imfill(im4,[1 1]);
if( im5(dim(1),dim(2)) ~= 1 )
	im6 = imfill(im4,[dim(1) dim(2)]);
	im5 = im5|im6;
end
if( im5(1,dim(2)) ~= 1 )
	im6 = imfill(im4,[1, dim(2)]);
	im5 = im5|im6;
end	
if( im5(dim(1),1) ~= 1 )
	im6 = imfill(im4,[dim(1) 1]);
	im5 = im5|im6;
end

im5 = logical(im5-im4);	% Outside
imbody = logical(1-im5);
return;