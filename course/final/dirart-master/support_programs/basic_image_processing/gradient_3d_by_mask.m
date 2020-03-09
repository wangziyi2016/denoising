function [Iy,Ix,Iz] = gradient_3d_by_mask(img,mask)
%
% [Iy,Ix,Iz] = gradient_3d_by_mask(img,mask)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('mask','var')
	mask = [-1 8 0 -8 1]/12;
	if sum(isnan(img(:))) > 0
		mask = [0 1 0 -1 0]/2;
	end
end

dim = mysize(img);
cy = 1:dim(1);
cx = 1:dim(2);
cz = 1:dim(3);

Iy = mask(1)*img(min(cy+2,dim(1)),:,:) + mask(2)*img(min(cy+1,dim(1)),:,:) + mask(4)*img(max(cy-1,1),:,:) + mask(5)*img(max(cy-2,1),:,:);
Ix = mask(1)*img(:,min(cx+2,dim(2)),:) + mask(2)*img(:,min(cx+1,dim(2)),:) + mask(4)*img(:,max(cx-1,1),:) + mask(5)*img(:,max(cx-2,1),:);

if dim(3) == 1
	Iz = zeros(dim,'single');
else
	Iz = mask(1)*img(:,:,min(cz+2,dim(3))) + mask(2)*img(:,:,min(cz+1,dim(3))) + mask(4)*img(:,:,max(cz-1,1)) + mask(5)*img(:,:,max(cz-2,1));
end

