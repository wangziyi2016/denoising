function [mvy,mvx,mvz] = recalculate_mvs_as_2D_slices_interpne(mvy,mvx,mvz)
%
% Upscale the motion field
%
% [mvy,mvx,mvz] = recalculate_mvs_as_2D_slices(mvy,mvx,mvz)
% 
dim = size(mvy);
dim2 = [dim(1)*2 dim(2)*2 dim(3)];

y = single([0.5:0.5:dim(1)]+0.25);
x = single([0.5:0.5:dim(2)]+0.25);
z = 1:dim(3);

[xx,yy,zz] = meshgrid(x,y,z);
vxyz = [yy(:) xx(:) zz(:)];

disp('Recalculating mvx ...');
mvx = interpne(mvx,vxyz);
mvx = reshape(mvx,dim2);

disp('Recalculating mvy ...');
mvy = interpne(mvy,vxyz);
mvy = reshape(mvy,dim2);

disp('Recalculating mvz ...');
mvz = interpne(mvz,vxyz);
mvz = reshape(mvz,dim2);


