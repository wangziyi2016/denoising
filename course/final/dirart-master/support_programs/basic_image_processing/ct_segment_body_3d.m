function imbody = ct_segment_body_3d(im,thres,boundary,forcelimits)
%
% imbody = ct_segment_body_3d(im,thres,boundary,forcelimits)
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
	disp('imbody = ct_segment_body_3d(im,thres,boundary,forcelimits)');
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
z = round(dim(3)/2);


im2d = im(:,:,z);
im2d = im2d>thres;

if exist('forcelimits','var') && ~isempty(forcelimits)
	im2d(:,1:forcelimits(1))=0;
	im2d(:,forcelimits(2):end)=0;
	im2d(1:forcelimits(3),:)=0;
	im2d(forcelimits(4):end,:)=0;
	im2(:,1:forcelimits(1),:)=0;
	im2(:,forcelimits(2):end,:)=0;
	im2(1:forcelimits(3),:,:)=0;
	im2(forcelimits(4):end,:,:)=0;
end


se = strel('disk',15);
im2d = imopen(im2d,se);

%ims = lowpass3d(single(im),2);
[maxv,maxI] = max(im2d(:));
[x,y]=ind2sub(size(im2d),maxI);

im3 = logical(1-im2);
im4 = imfill(im3,[x y z]);
im4 = logical(im4-im3);

dim = size(im);

im5 = imfill(im4,[1 1 1]);
if( im5(dim(1),dim(2),dim(3)) ~= 1 )
	im6 = imfill(im4,[dim(1) dim(2) dim(3)]);
	im5 = im5|im6;
end
if( im5(1,dim(2),dim(3)) ~= 1 )
	im6 = imfill(im4,[1, dim(2) dim(3)]);
	im5 = im5|im6;
end	
if( im5(dim(1),1,1) ~= 1 )
	im6 = imfill(im4,[dim(1), 1 1]);
	im5 = im5|im6;
end

im5 = logical(im5-im4);	% Outside
imbody = logical(1-im5);

se = strel('disk',boundary);
imbody = imdilate(imbody,se);
%sd = direct_sdist_3din2d(imbody,0,1);
%imbody = sd > -boundary;
return;