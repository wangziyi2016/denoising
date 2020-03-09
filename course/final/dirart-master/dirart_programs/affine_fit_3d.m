function [G,dx2,dy2,dz2]=affine_fit_3d(dx,dy,dz,xxx,yyy,zzz,mask)
%
% Affine transformation approximation to motion vector field
%
% Function:		[G,dx2,dy2,dz2] = affine_fit(dv,xx,yy)
%
%	Input:	dv,dy,dz	-	motion values
%			xxx,yyy,zzz	-	position values
%	Output:	G			-	transform matrix
%			dx2,dy2,dz2 -	fitted motion values
%
%	This function will calculate the transformation matrix G so that 
%	v = G*pos in mean sqaure sense. If xx,yy are omit, it will be
%	automatically calculate from the matrix dx and dy. 
%	For 3D, the result G will be a 4x4 matrix and the 4rd row is [0 0 0 1].
%
% Copyrighted by: Deshan Yang, WUSTL, 07/2006
%
dim = mysize(dx);

% NM = prod(dim);

if( ~exist('mask','var') || isempty(mask) )
	mask = ones(dim,'single');
end

if( ~exist('yyy','var') || isempty(yyy) )
	x0 = 1:dim(2);
	y0 = 1:dim(1);
	z0 = 1:dim(3);
	[xxx,yyy,zzz] = meshgrid(x0,y0,z0);	% xx, yy are the original coordinates of image pixels
end

maskidx = find(mask~=0)';

xxv = xxx(maskidx);
yyv = yyy(maskidx);
zzv = zzz(maskidx);
xyzv = [xxv;yyv;zzv;ones(size(xxv))];
X = xyzv';

meandx = mean(dx(:));
meandy = mean(dy(:));
meandz = mean(dz(:));
dxv = dx(maskidx)-meandx;
dyv = dy(maskidx)-meandy;
dzv = dz(maskidx)-meandz;

tempxv = dxv + xxv; tempxv = tempxv';
tempyv = dyv + yyv; tempyv = tempyv';
tempzv = dzv + zzv; tempzv = tempzv';

% Compute the fitting parameters
a = X\tempxv;	
b = X\tempyv;
c = X\tempzv;

G = [a';b';c';0 0 0 1];	% The least square approximated affine transformation matrix
G(1,4) = G(1,4)+meandx;
G(2,4) = G(2,4)+meandy;
G(3,4) = G(3,4)+meandz;
dG=G;dG(1,1)=dG(1,1)-1;dG(2,2)=dG(2,2)-1;dG(3,3)=dG(3,3)-1;


if nargout > 1
	% Compute the fitted dx and dy
	dxyzv = dG*xyzv;
	% dx2 = reshape(dxyzv(1,:),dim);
	% dy2 = reshape(dxyzv(2,:),dim);
	% dz2 = reshape(dxyzv(3,:),dim);

	dx2 = zeros(dim,'single'); dy2=dx2;dz2=dx2;
	dx2(maskidx) = dxyzv(1,:);
	dy2(maskidx) = dxyzv(2,:);
	dz2(maskidx) = dxyzv(3,:);
end

