function [mvy,mvx,mvz] = recalculate_mvs_as_2D_slices(mvy,mvx,mvz,displayflag)
%
% Upscale the motion field
%
% [mvy,mvx,mvz] = recalculate_mvs_as_2D_slices(mvy,mvx,mvz,displayflag)
% 
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('displayflag')
	displayflag = 1;
end

cur_dim = mysize(mvy);
dim = cur_dim*2;
dim(3)=cur_dim(3);

if cur_dim(3) == 1
	dim(3) = 1;
end

x0 = single([1:dim(2)]);
y0 = single([1:dim(1)]);
z0 = single([1:dim(3)]);
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

laststep_y = single([1:2:cur_dim(1)*2]+0.5);
laststep_x = single([1:2:cur_dim(2)*2]+0.5);
laststep_z = 1:cur_dim(3);

% if dim(3) == 1
% 	[laststep_xx,laststep_yy] = meshgrid(laststep_x,laststep_y);
%     laststep_zz = ones(size(laststep_xx));
% else
% 	[laststep_xx,laststep_yy,laststep_zz] = meshgrid(laststep_x,laststep_y,laststep_z);
% end

if (displayflag == 1)
	H = waitbar(0,'Recalculating mvx ...');
	set(H,'Name','Recalculating mvx');
	set(H,'NumberTitle','off');
end

if cur_dim(3) > 1
    fprintf('Recalculating mvx ...');
    %mvx = interpn(laststep_yy,laststep_xx,laststep_zz,mvx,yy,xx,zz,'spline')*2;
    %mvx = interp3(laststep_xx,laststep_yy,laststep_zz,mvx,xx,yy,zz,'spline')*2;
	%mvx = interp3wrapper(laststep_xx,laststep_yy,laststep_zz,mvx,xx,yy,zz,'spline',[],200*100*100)*2;
    mvx = interp3wrapper(laststep_x,laststep_y,laststep_z,mvx,xx,yy,zz,'linear',0,200*100*100)*2;

    if (displayflag == 1) waitbar(0.33,H,'Recalculate mvy ...'); end
    fprintf(', mvy ...');
	%mvy = interpn(laststep_yy,laststep_xx,laststep_zz,mvy,yy,xx,zz,'spline')*2;
	%mvy = interp3(laststep_xx,laststep_yy,laststep_zz,mvy,xx,yy,zz,'spline')*2;
	%mvy\ = interp3wrapper(laststep_xx,laststep_yy,laststep_zz,mvy,xx,yy,zz,'spline',[],200*100*100)*2;
    mvy = interp3wrapper(laststep_x,laststep_y,laststep_z,mvy,xx,yy,zz,'linear',0,200*100*100)*2;

    if (displayflag == 1) waitbar(0.67,H,'Recalculate mvz ...'); end
    fprintf(', mvz ...');
	%mvz = interpn(laststep_yy,laststep_xx,laststep_zz,mvz,yy,xx,zz,'spline')*2;
	%mvz = interp3(laststep_xx,laststep_yy,laststep_zz,mvz,xx,yy,zz,'spline');
	%mvz = interp3wrapper(laststep_xx,laststep_yy,laststep_zz,mvz,xx,yy,zz,'spline',[],200*100*100);
    mvz = interp3wrapper(laststep_x,laststep_y,laststep_z,mvz,xx,yy,zz,'linear',0,200*100*100);
	fprintf('\n');
else
	mvx = interp2(laststep_x,laststep_y,mvx,xx,yy,'spline')*2;
	if (displayflag == 1) waitbar(0.33,H,'Recalculate mvy ...'); end
	mvy = interp2(laststep_x,laststep_y,mvy,xx,yy,'spline')*2;
	mvz = zeros(size(mvy),class(mvy));
end

if (displayflag == 1) 
	close(H); 
end



