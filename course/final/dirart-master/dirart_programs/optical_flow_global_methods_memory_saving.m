function [Vy,Vx,Vz] = optical_flow_global_methods_memory_saving(method,mainfigure,img1,imgt,voxelsizes,maxiter,stop,offsets)
%
% Horn-Schunck optical flow method
%
% Implemented by: Deshan Yang, 09/2006
%
% Input parameters:
% img1	-	Image to be registered
% imgt	-	The target image (the reference)
% method	= 1	regular method
%			= 2	reverse consistent
%
% Outputs:
% Vy,Vx,Vz	-	The motion fields
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

max_intensity = max(max(img1(:)),max(imgt(:)));

if ~exist('maxiter','var') || isempty(maxiter)
	maxiter = 20;
end

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

if ~exist('offsets','var') || isempty(offsets)
	offsets = [0 0 0];
elseif length(offsets) == 1
	offsets = [0 0 offsets];
end

if length(voxelsizes) == 1
	voxelsizes = [1 1 voxelsizes];
end

dim=mysize(imgt);
yoffs = (1:dim(1))+offsets(1);
xoffs = (1:dim(2))+offsets(2);
zoffs = (1:dim(3))+offsets(3);

Vy = zeros(dim,'single'); Vx=Vy;Vz=Vy;

windowtitle = 'Original Horn-Schunck';

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

[Iy,Ix,Iz] = gradient_3d_by_mask(img1);
Iy = Iy(yoffs,xoffs,zoffs)*voxelsizes(1);
Ix = Ix(yoffs,xoffs,zoffs)*voxelsizes(2);
Iz = Iz(yoffs,xoffs,zoffs)*voxelsizes(3);

if method == 2
	% reverse consistent
	[Iy2,Ix2,Iz2] = gradient_3d_by_mask(imgt);
	Iy2 = Iy2*voxelsizes(1);
	Ix2 = Ix2*voxelsizes(2);
	Iz2 = Iz2*voxelsizes(3);

	Iy = (Iy+Iy2);
	Ix = (Ix+Ix2);
	Iz = (Iz+Iz2);
	clear Iy2 Ix2 Iz2;
end

img1 = img1(yoffs,xoffs,zoffs);
It = imgt - img1;
clear imgt img1;

% Parameters
lambda = 0.2*max_intensity;
fprintf('Lambda = %d\n',lambda);

suma = lambda*lambda + Ix.^2 + Iy.^2 + Iz.^2;

if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s',windowtitle)]); drawnow; end

max_motion_per_iteration = 0.5;

for i=1:maxiter
	S = 10;	% max number of slices
	maxv = 0;
	for z = 1:S:dim(3)
		K = floor(z/S)+1;
		if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s - Iter %d (%d) . %d',windowtitle,i,maxiter,K)]); drawnow; end
		z2 = z+S-1;
		z2 = min(z2,dim(3));

		zs1 = z:z2;
		zs2 = max(z-1,1):min(z2+1,dim(3));
		zs3 = (1:length(zs1))+find(zs2==z,1,'first')-1;

		[Vya,Vxa,Vza]=hs_velocity_avg3d(Vy(:,:,zs2),Vx(:,:,zs2),Vz(:,:,zs2));
		Vya = Vya(:,:,zs3);
		Vxa = Vxa(:,:,zs3);
		Vza = Vza(:,:,zs3);

		Vy0 = Vy(:,:,zs1);
		Vx0 = Vx(:,:,zs1);
		Vz0 = Vz(:,:,zs1);

		sumb = Iy(:,:,zs1).*Vya + Ix(:,:,zs1).*Vxa + Iz(:,:,zs1).*Vza;
		Vy(:,:,zs1) = Vya-(Iy(:,:,zs1).*sumb+It(:,:,zs1).*Iy(:,:,zs1))./suma(:,:,zs1);
		Vx(:,:,zs1) = Vxa-(Ix(:,:,zs1).*sumb+It(:,:,zs1).*Ix(:,:,zs1))./suma(:,:,zs1);
		Vz(:,:,zs1) = Vza-(Iz(:,:,zs1).*sumb+It(:,:,zs1).*Iz(:,:,zs1))./suma(:,:,zs1);
		clear sumb Vya Vxa Vza;

		% Limit the motion field update per iteration
		dV = sqrt(abs(Vy0 - Vy(:,:,zs1)).^2 + abs(Vx0-Vx(:,:,zs1)).^2 + abs(Vz0-Vz(:,:,zs1)).^2);
		if max(dV(:)) > max_motion_per_iteration
			idxes = find( dV > max_motion_per_iteration );
			TempVy = Vy(:,:,zs1); 
			TempVx = Vx(:,:,zs1); 
			TempVz = Vz(:,:,zs1); 
			dVy = TempVy(idxes) - Vy0(idxes);
			dVx = TempVx(idxes) - Vx0(idxes);
			dVz = TempVz(idxes) - Vz0(idxes);
			dVy = dVy * max_motion_per_iteration ./ dV(idxes);
			dVx = dVx * max_motion_per_iteration ./ dV(idxes);
			dVz = dVz * max_motion_per_iteration ./ dV(idxes);
			TempVy(idxes) = Vy0(idxes)+dVy; Vy(:,:,zs1) = TempVy; clear TempVy;
			TempVx(idxes) = Vx0(idxes)+dVx; Vx(:,:,zs1) = TempVx; clear TempVx;
			TempVz(idxes) = Vz0(idxes)+dVz; Vz(:,:,zs1) = TempVz; clear TempVz;
			dV(idxes) = max_motion_per_iteration;
			clear dVy dVx dVz idxes;
		end
		clear Vy0 Vx0 Vz0;
		maxv = max(maxv,max(dV(:)));
		clear dV;
	end

	% Update display
	if ~isempty(mainfigure)
		handles = guidata(mainfigure);
		%if get(handles.gui_handles.motioncheckbox,'Value') == 1
		%if strcmp(get(handles.gui_handles.OptionsDisplayMotionVectorMenuItem,'Checked'),'on') == 1
		if GetMotionDisplaySelection(handles) > 1
			handles = guidata(mainfigure);
			handles.reg.mvx_pass = Vx;
			handles.reg.mvy_pass = Vy;
			handles.reg.mvz_pass = Vz;

			guidata(mainfigure,handles);
			ConditionalRefreshDisplay(handles,1:9);
		end
		clear handles;
	end

	fprintf('Iteration %d: max movement: %d\n',i,maxv);

	if maxv <= stop
		break;
	end

	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		return;	% break out off the loop
	end
end

if (~isempty(mainfigure)), set(mainfigure,'Name',figureTitle); drawnow; end

return


