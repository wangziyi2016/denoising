function grad = gradient_1d_by_mask(img,dim2compute,mask)
%
% grad = gradient_1d_by_mask(img,dim2compute=1,mask=[-1 8 0 -8 1]/12)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('mask','var') || isempty(mask)
	mask = [-1 8 0 -8 1]/12;
end

dim = size(img);

switch dim2compute
	case 1
		cy = 1:dim(1);
		grad = mask(1)*img(min(cy+2,dim(1)),:,:) + mask(2)*img(min(cy+1,dim(1)),:,:) + mask(4)*img(max(cy-1,1),:,:) + mask(5)*img(max(cy-2,1),:,:);
	case 2
		cx = 1:dim(2);
		grad = mask(1)*img(:,min(cx+2,dim(2)),:) + mask(2)*img(:,min(cx+1,dim(2)),:) + mask(4)*img(:,max(cx-1,1),:) + mask(5)*img(:,max(cx-2,1),:);
	case 3
		cz = 1:dim(3);
		grad = mask(1)*img(:,:,min(cz+2,dim(3))) + mask(2)*img(:,:,min(cz+1,dim(3))) + mask(4)*img(:,:,max(cz-1,1)) + mask(5)*img(:,:,max(cz-2,1));
end

