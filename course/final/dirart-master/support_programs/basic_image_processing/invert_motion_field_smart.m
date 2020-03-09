function [imvy,imvx,imvz,offsets,mask]= invert_motion_field_smart(mvy,mvx,mvz,result_in_same_dim)
% 
% [imvy,imvx,imvz,offsets,mask]= invert_motion_field_smart(mvy,mvx,mvz)
% [imvy,imvx,imvz]= invert_motion_field_smart(mvy,mvx,mvz,1)
% 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('result_in_same_dim','var')
	result_in_same_dim = 0;
end

dim = mysize(mvy);
y0 = 1:dim(1); x0 = 1:dim(2); z0 = 1:dim(3);
[xx,yy,zz] = meshgrid(x0,y0,z0);
xx = xx - mvx;
yy = yy - mvy;
zz = zz - mvz;

minz = min(floor(min(zz(:))),1);
maxz = max(ceil(max(zz(:))),dim(3));
zs = minz:maxz;
offsets(3) = 1-minz;

minx = min(floor(min(xx(:))),1);
maxx = max(ceil(max(xx(:))),dim(2));
xs = minx:maxx;
offsets(2) = 1-minx;

miny = min(floor(min(yy(:))),1);
maxy = max(ceil(max(yy(:))),dim(1));
ys = miny:maxy;
offsets(1) = 1-miny;

dim2 = [length(ys) length(xs) length(zs)];

[mvy2,mvx2,mvz2] = expand_motion_field(mvy,mvx,mvz,dim2,offsets);

fprintf('Inverting motion fields ...');
cp1 = cputime;
[imvy,imvx,imvz] = invert_motion_field(mvy2,mvx2,mvz2);
fprintf(', used %.2f s\n',cputime-cp1);

[xx,yy,zz] = meshgrid(minx:maxx,miny:maxy,minz:maxz);

xx = xx - imvx;
yy = yy - imvy;
zz = zz - imvz;

mask = (zz<= (dim(3)+0.5) & zz>= 0.5 & xx <= (dim(2)+0.5) & xx >= 0.5 & yy <= (dim(1)+0.5) & yy >= 0.5);


if result_in_same_dim == 1
	ys = offsets(1) + (1:dim(1));
	xs = offsets(2) + (1:dim(2));
	zs = offsets(3) + (1:dim(3));
	imvy = imvy(ys,xs,zs);
	imvx = imvx(ys,xs,zs);
	imvz = imvz(ys,xs,zs);
	mask = mask(ys,xs,zs);
	offsets = [ 0 0 0 ];
end





