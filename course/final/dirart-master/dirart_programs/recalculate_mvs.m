function [mvy,mvx,mvz] = recalculate_mvs(mvy,mvx,mvz,displayflag)
%
% Double sampling the motion field, used by the multigrid methods
%
% [mvy,mvx,mvz] = recalculate_mvs(mvy,mvx,mvz,displayflag)
% 
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('displayflag','var')
	displayflag = 1;
end

cur_dim = mysize(mvy);
dim = cur_dim*2;
if cur_dim(3) == 1
	dim(3) = 1;
end

x0 = single(1:dim(2));
y0 = single(1:dim(1));
z0 = single(1:dim(3));
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

laststep_y = single((1:2:dim(1))+0.5);
laststep_x = single((1:2:dim(2))+0.5);
laststep_z = single((1:2:dim(3))+0.5);

if dim(3) == 1
	laststep_z = 1;
end

if (displayflag == 1)
	H = waitbar(0,'Recalculating mvx ...');
	set(H,'Name','Recalculating mvx');
	set(H,'NumberTitle','off');
else
	fprintf('Recalculating mvx ...');
end

if cur_dim(3) > 1
	%mvx = interp3wrapper(laststep_x,laststep_y,laststep_z,mvx,xx,yy,zz,'spline')*2;
	mvx = interp_one_mv(laststep_x,laststep_y,laststep_z,mvx,xx,yy,zz)*2;
	
	if (displayflag == 1)
		waitbar(0.33,H,'Recalculate mvy ...'); 
	else
		fprintf(', mvy ...'); 
	end
	%mvy = interp3wrapper(laststep_x,laststep_y,laststep_z,mvy,xx,yy,zz,'spline')*2;
	mvy = interp_one_mv(laststep_x,laststep_y,laststep_z,mvy,xx,yy,zz)*2;
	
	if (displayflag == 1)
		waitbar(0.67,H,'Recalculate mvz ...'); 
	else
		fprintf(', mvz ...'); 
	end
	%mvz = interp3wrapper(laststep_x,laststep_y,laststep_z,mvx,xx,yy,zz,'spline')*2;
	mvz = interp_one_mv(laststep_x,laststep_y,laststep_z,mvz,xx,yy,zz)*2;
else
	mvx = interp2(laststep_x,laststep_y,mvx,xx,yy,'spline')*2;
	if (displayflag == 1) 
		waitbar(0.33,H,'Recalculate mvy ...'); 
	else
		fprintf(', mvy ...'); 
	end
	mvy = interp2(laststep_x,laststep_y,mvy,xx,yy,'spline')*2;
	mvz = zeros(size(mvy),class(mvy));
end

if (displayflag == 1)
	close(H); 
else
	fprintf('\n');
end
drawnow;
pause(0.1);

return;


function mvout = interp_one_mv(x,y,z,mvin,xx,yy,zz)
dim = size(mvin)*2;
mvout = zeros(dim,'single');
% mask = zeros(dim,'int8');
% mask(2:end-1,2:end-1,2:end-1) = 1;
% mask = logical(mask);

mvout(2:end-1,2:end-1,2:end-1) = interp3wrapper(x,y,z,mvin,xx(2:end-1,2:end-1,2:end-1),yy(2:end-1,2:end-1,2:end-1),zz(2:end-1,2:end-1,2:end-1),'linear',0);
%clear mask;
%mvout(mask) = interp3(x,y,z,mvin,xx(mask),yy(mask),zz(mask),'spline');

% mvout(1,:,:) = interp3(x,y,z,mvin,xx(1,:,:),yy(1,:,:),zz(1,:,:),'spline');
% mvout(end,:,:) = interp3(x,y,z,mvin,xx(end,:,:),yy(end,:,:),zz(end,:,:),'spline');
% mvout(:,1,:) = interp3(x,y,z,mvin,xx(:,1,:),yy(:,1,:),zz(:,1,:),'spline');
% mvout(:,end,:) = interp3(x,y,z,mvin,xx(:,end,:),yy(:,end,:),zz(:,end,:),'spline');
% mvout(:,:,1) = interp3(x,y,z,mvin,xx(:,:,1),yy(:,:,1),zz(:,:,1),'spline');
% mvout(:,:,end) = interp3(x,y,z,mvin,xx(:,:,end),yy(:,:,end),zz(:,:,end),'spline');

% mvout(1,:,:) = interp3(x,y(1:2),z,mvin(1:2,:,:),xx(1,:,:),yy(1,:,:),zz(1,:,:),'spline');
% mvout(end,:,:) = interp3(x,y(end-1:end),z,mvin(end-1:end,:,:),xx(end,:,:),yy(end,:,:),zz(end,:,:),'spline');
% mvout(:,1,:) = interp3(x(1:2),y,z,mvin(:,1:2,:),xx(:,1,:),yy(:,1,:),zz(:,1,:),'spline');
% mvout(:,end,:) = interp3(x(end-1:end),y,z,mvin(:,end-1:end,:),xx(:,end,:),yy(:,end,:),zz(:,end,:),'spline');
% mvout(:,:,1) = interp3(x,y,z(1:2),mvin(:,:,1:2),xx(:,:,1),yy(:,:,1),zz(:,:,1),'spline');
% mvout(:,:,end) = interp3(x,y,z(end-1:end),mvin(:,:,end-1:end),xx(:,:,end),yy(:,:,end),zz(:,:,end),'spline');

mvout(1,:,:) = mvout(2,:,:);
mvout(end,:,:) = mvout(end-1,:,:);
mvout(:,1,:) = mvout(:,2,:);
mvout(:,end,:) = mvout(:,end-1,:);
mvout(:,:,1) = mvout(:,:,2);
mvout(:,:,end) = mvout(:,:,end-1);

return;




