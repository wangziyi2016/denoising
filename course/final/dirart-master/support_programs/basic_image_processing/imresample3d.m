function imnew = imresample3d(im,varargin)
%
% imnew = imresample3d(im,newdims)
% imnew = imresample3d(im,old_vol_size,new_vol_size)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

imclass = class(im);

im= single(im);

if nargin == 3
	olddims = size(im);
	old_vol_size = varargin{1};
	new_vol_size = varargin{2};
	newdims = round(olddims.*old_vol_size./new_vol_size);
else
	newdims = varargin{1};
end

if ndims(im) == 3
	siz = size(im);

	x1 = [0:siz(1)/(newdims(1)):siz(1)-1]+1;
	x2 = [0:siz(2)/(newdims(2)):siz(2)-1]+1;
	x3 = [0:siz(3)/(newdims(3)):siz(3)-1]+1;

	[X2,X1] = meshgrid(x2,x1);

	if length(x1) == newdims(1) && length(x2) == newdims(2)
		imnew0 = im;
	else
		for i=1:siz(3)
			imnew0(:,:,i) = interp2(im(:,:,i),X2,X1,'linear',0);
		end
	end

	for i=1:newdims(1)
		for j=1:newdims(2)
			b = imnew0(i,j,:);
			b = reshape(b,1,siz(3));
			imnew(i,j,:) = interp1(b,x3,'linear',0);
		end
	end
	
else
	siz0 = size(im);
	im = squeeze(im);

	siz = size(im);
	x1 = [0:siz(1)/(newdims(1)):siz(1)-1]+1;
	x2 = [0:siz(2)/(newdims(2)):siz(2)-1]+1;

	[X1,X2] = meshgrid(x1,x2);

	imnew = interp2(im,X1,X2,'linear');
	imnew = reshape(imnew,siz0);
end

imnew = cast(imnew,imclass);

