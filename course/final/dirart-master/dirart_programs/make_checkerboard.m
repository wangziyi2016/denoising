function X=make_checkerboard(x1,x2,checksize,colorweight,offsets)
%{
Making the checkerboard image from two images

X=make_checkerboard(x1,x2,checksize,colorweight)


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}


if( ~exist('colorweight','var') )
	colorweight = 0.1;
end

if ~exist('offsets','var')
	offsets = [1 1];
end

if ndims(checksize) == 1
	checksize = [checksize checksize];
end

dim = size(x1);

% checksize = min(dim/4,checksize);
% checksize = max(checksize,10);

mask=mycheckerboard(checksize,ceil(dim(1)/checksize(1)),ceil(dim(2)/checksize(2)));
mask=mask(1+offsets(1):dim(1)+offsets(1),1+offsets(2):dim(2)+offsets(2));
mask = mask > 0.5;

x1b = x1.*(mask==0);
x1b(mask==1) = 0;
x2b = x2.*(mask==1);
x2b(mask==0)=0;
x = x1b + x2b;
% x = x1.*(mask==0) + x2.*(mask==1);


X(:,:,1)=x;
X(:,:,2)=x;
X(:,:,3)=x;

val = max(x(:));

X(:,:,1)=X(:,:,1)+(mask==1)*val*colorweight;
X(:,:,2)=X(:,:,2)+(mask==1)*val*colorweight;

X(isnan(X))=0;
X = min(X,val);

return;


function I = mycheckerboard(n,p,q)

if ndims(n) == 1
	n = [n n];
end

black = zeros(n);
white = ones(n);
tile = [black white; white black];
I = repmat(tile,p,q);

% make right half plane have light gray tiles
ncols = size(I,2);
midcol = ncols/2 + 1; 
I(:,midcol:ncols) = I(:,midcol:ncols) - .3;
I(I<0) = 0;


return;

