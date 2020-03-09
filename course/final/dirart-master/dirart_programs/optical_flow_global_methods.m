function varargout = optical_flow_global_methods(method,mainfigure,img1,imgt,voxelsizes,maxiter,stop,mvy0,mvx0,mvz0,offsets,mask0,smoothing)
%
% Gloabl optical flow methods
%
% Implemented by: Deshan Yang, 09/2006
%
% Input parameters:
% img1	-	Image to be registered
% imgt	-	The target image (the reference)
% method	-	1 - original Horn-Schunck method
%				2 - Issam modification: weighted smoothness
%				3 - Combined local LMS and HS global smoothness
%				4 - Combined local LMS and Issam's weighted smoothness
%				5 - Horn-Schunck and weighted panalization on optical flow
%				    constraint
%				6 - Horn-Schunck with divergence constraints for
%				    uncompressible media
%
%		All method value could be presented in string of binary values
%		bit		1:	0/1 - Issam weighted smoothness on/off
%				2:	0/1	- Combined local and global, on/off
%				3:	0/1	- Divergerency constraint on/off
%				5:	0/1	- Inverse consistency (averging gradient of I1 and I2), on/off
%
% Outputs:
% u,v,w	-	The motion fields
%
% changes 10/21/2006
% Allow img1 to be larger than img2 with zoffset so that gradient in z
% direction could be computed more accurately
%
% 05/11/2007
% Allow image offsets in all x,y,z direction
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

max_intensity = max(max(img1(:)),max(imgt(:)));

if ~exist('smoothing','var') || isempty(smoothing)
	smoothing = 3;
end

smoothing = smoothing(1);

if smoothing < 1
	lambda00 = smoothing;
elseif smoothing == 1
	lambda00 = 0.05;
elseif smoothing <= 2
	lambda00 = 0.1;
elseif smoothing <= 3
	lambda00 = 0.2;
elseif smoothing <= 4
	lambda00 = 0.3;
elseif smoothing <= 5
	lambda00 = 0.4;
else
	lambda00 = 0.5;
end	
	

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

if ~ischar(method)
	method = fliplr(dec2bin(method-1,3));
end
options = str2num(method');
options2 = zeros(1,10);
options2(1:length(options)) = options;
options = options2;


dim=mysize(imgt);
yoffs = (1:dim(1))+offsets(1);
xoffs = (1:dim(2))+offsets(2);
zoffs = (1:dim(3))+offsets(3);

Vy = zeros(dim,'single'); Vx=Vy;Vz=Vy;

if ~exist('mvx0','var') || isempty(mvx0)
	options(3) = 0;	% Disable divergence constraint
end

titles1{1} = 'Original Horn-Schunck';
titles1{2} = 'Horn-Schunck with weighted global smoothness';
titles2{1} = '';
titles2{2} = ' with local LMS';
titles3{1} = '';
titles3{2} = ' and divergence constraint';
titles5{1} = '';
titles5{2} = ' and inverse consistency';


windowtitle = [titles1{options(1)+1} titles2{options(2)+1} titles3{options(3)+1} titles5{options(5)+1}];

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

[Iy,Ix,Iz] = gradient_3d_by_mask(img1);

% Iy(isnan(Iy)) = 0;
% Ix(isnan(Ix)) = 0;
% Iz(isnan(Iz)) = 0;

Iy = Iy(yoffs,xoffs,zoffs)*voxelsizes(1);
Ix = Ix(yoffs,xoffs,zoffs)*voxelsizes(2);
Iz = Iz(yoffs,xoffs,zoffs)*voxelsizes(3);

img1 = img1(yoffs,xoffs,zoffs);
if options(5) == 1
	[Iy2,Ix2,Iz2] = gradient_3d_by_mask(imgt);
% 	Iy2(isnan(Iy2))=0;
% 	Ix2(isnan(Ix2))=0;
% 	Iz2(isnan(Iz2))=0;
	Iy2 = Iy2*voxelsizes(1);
	Ix2 = Ix2*voxelsizes(2);
	Iz2 = Iz2*voxelsizes(3);
	Iy = (Iy+Iy2); clear Iy2;
	Ix = (Ix+Ix2); clear Ix2;
	Iz = (Iz+Iz2); clear Iz2;
end

It = imgt - img1;
% It(isnan(It))=0;

if options(1) == 0	% Original Horn-Schunck method
	% Parameters
	lambda = lambda00*max_intensity;
	fprintf('Lambda = %d\n',lambda);

	suma = lambda*lambda + Ix.^2 + Iy.^2 + Iz.^2;
else % Issam's modification - weighted smoothness
	% Parameters
	T = 0.05*max_intensity;
	lambda0 = lambda00*max_intensity;
	fprintf('T = %d, Lambda0 = %d\n',T,lambda0);

	sgrad=sqrt(Ix.^2+Iy.^2+Iz.^2);
	sgrad = sgrad / max(sgrad(:));

	lambda1=lambda0/2*(1+exp(-sgrad/T));
	% initialize params...
	lambda2=lambda1.*lambda1;
	suma = lambda2+Ix.^2+Iy.^2+Iz.^2;
end

if options(2) == 1 % Combing local LMS and global smoothness
	% Computing the Gaussian mask
	Ws = single([0.0625 0.25 0.375 0.25 0.0625]);
	if dim(3) == 1
		W = ones(5,5,1,'single');
		for k=1:5
			W(k,:,:) = W(k,:,:) * Ws(k);
			W(:,k,:) = W(:,k,:) * Ws(k);
		end
	else
		W = ones(5,5,5,'single');
		for k=1:5
			W(k,:,:) = W(k,:,:) * Ws(k);
			W(:,k,:) = W(:,k,:) * Ws(k);
			W(:,:,k) = W(:,:,k) * Ws(k);
		end
	end
	W2 = W.*W;

	% Smoothing the gradient fields
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iy*Iy ...']); drawnow; end
	IyIy = conv3dmask(Iy.*Iy,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iy*Ix ...']); drawnow; end
	IyIx = conv3dmask(Iy.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iy*Iz ...']); drawnow; end
	IyIz = conv3dmask(Iy.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Ix*Ix ...']); drawnow; end
	IxIx = conv3dmask(Ix.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Ix*Iz ...']); drawnow; end
	IxIz = conv3dmask(Ix.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iz*Iz ...']); drawnow; end
	IzIz = conv3dmask(Iz.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Iy ...']); drawnow; end
	ItIy = conv3dmask(It.*Iy,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Ix ...']); drawnow; end
	ItIx = conv3dmask(It.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Iz ...']); drawnow; end
	ItIz = conv3dmask(It.*Iz,W2);
else
	ItIy = It.*Iy;
	ItIx = It.*Ix;
	ItIz = It.*Iz;
end

if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s',windowtitle)]); drawnow; end

max_motion_per_iteration = 0.5;
%max_motion_per_iteration = 0.5;

fprintf('Starting maximal %d iterations:\n',maxiter);
for iter=1:maxiter
% 	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s - Iter %d off %d',windowtitle,iter,maxiter)]); drawnow; end
	[Vya,Vxa,Vza]=hs_velocity_avg3d(Vy,Vx,Vz);
% 	[Vya,Vxa,Vza]=hs_velocity_avg3d_weighted(Vy,Vx,Vz,1,[],Iy,Ix,Iz);
% 	[Vya,Vxa,Vza]=hs_velocity_avg3d_weighted(Vy,Vx,Vz,2,[],Iy,Ix,Iz);
	
	Vy0 = Vy; Vx0 = Vx; Vz0 = Vz;
	
	if length(options) >= 3 && options(3) == 1	
		% Divergence constraint
		lambda2 = 0.005*max_intensity;

		Vyy =					gradient_3d_by_mask(mvy0+Vy);
		[dummy1,Vxx] =			gradient_3d_by_mask(mvx0+Vx);
		[dummy1,dummy2,Vzz] =	gradient_3d_by_mask(mvz0+Vz);
		clear dummy1 dummy2;
		
		[Vyyy,Vyyx,Vyyz] = gradient_3d_by_mask(Vyy);
		ItIy2 = ItIy - lambda2*Vyyy; clear Vyyy;
		ItIx2 = ItIx - lambda2*Vyyx; clear Vyyx;
		ItIz2 = ItIz - lambda2*Vyyz; clear Vyyz;
		clear Vyy;
		
		[Vxxy,Vxxx,Vxxz] = gradient_3d_by_mask(Vxx);
		ItIy2 = ItIy2 - lambda2*Vxxy; clear Vxxy;
		ItIx2 = ItIx2 - lambda2*Vxxx; clear Vxxx;
		ItIz2 = ItIz2 - lambda2*Vxxz; clear Vxxz;
		clear Vxx;
		
		[Vzzy,Vzzx,Vzzz] = gradient_3d_by_mask(Vzz);
		ItIy2 = ItIy2 - lambda2*Vzzy; clear Vzzy;
		ItIx2 = ItIx2 - lambda2*Vzzx; clear Vzzx;
		ItIz2 = ItIz2 - lambda2*Vzzz; clear Vzzz;
		clear Vzz;
% 		ItIy2 = ItIy - lambda2*(Vyyy+Vxxy+Vzzy); clear Vyyy Vxxy Vzzy;
% 		ItIx2 = ItIx - lambda2*(Vyyx+Vxxx+Vzzx); clear Vyyx Vxxx Vzzx;
% 		ItIz2 = ItIz - lambda2*(Vyyz+Vxxz+Vzzz); clear Vyyz Vxxz Vzzz;
	else
		ItIy2 = ItIy;
		ItIx2 = ItIx;
		ItIz2 = ItIz;
	end

	if options(2) == 1
		dVy = 10*(Vya.*IyIy + Vxa.*IyIx + Vza.*IyIz + ItIy2) ./ suma;
		dVx = 10*(Vya.*IyIx + Vxa.*IxIx + Vza.*IxIz + ItIx2) ./ suma;
		dVz = 10*(Vya.*IyIz + Vxa.*IxIz + Vza.*IzIz + ItIz2) ./ suma;
	else
		sumb = Iy.*Vya + Ix.*Vxa + Iz.*Vza;
		dVy = (Iy.*sumb+ItIy2)./suma;
		dVx = (Ix.*sumb+ItIx2)./suma;
		dVz = (Iz.*sumb+ItIz2)./suma;
		clear sumb;
	end
	
	dVy(isnan(dVy)) = 0;
	dVx(isnan(dVx)) = 0;
	dVz(isnan(dVz)) = 0;
	Vy = Vya-dVy;
	Vx = Vxa-dVx;
	Vz = Vza-dVz;
	clear dVy dVx dVx;

	clear ItIy2 ItIx2 ItIz2;
	
% 	Vy(isnan(Vy)) = 0;
% 	Vx(isnan(Vx)) = 0;
% 	Vz(isnan(Vz)) = 0;
	
	% Limit the motion field update per iteration
	dV = sqrt(abs(Vy0 - Vy).^2 + abs(Vx0-Vx).^2 + abs(Vz0-Vz).^2);
	if max(dV(:)) > max_motion_per_iteration
		idxes = find( dV > max_motion_per_iteration );
		dVy = Vy(idxes) - Vy0(idxes);
		dVx = Vx(idxes) - Vx0(idxes);
		dVz = Vz(idxes) - Vz0(idxes);
		dVy = dVy * max_motion_per_iteration ./ dV(idxes);
		dVx = dVx * max_motion_per_iteration ./ dV(idxes);
		dVz = dVz * max_motion_per_iteration ./ dV(idxes);
		Vy(idxes) = Vy0(idxes)+dVy;
		Vx(idxes) = Vx0(idxes)+dVx;
		Vz(idxes) = Vz0(idxes)+dVz;
		dV(idxes) = max_motion_per_iteration;
		clear dVy dVx dVz idxes;
	end
	
	% Update display
% 	if ~isempty(mainfigure)
% 		handles = guidata(mainfigure);
% 		%if get(handles.gui_handles.motioncheckbox,'Value') == 1
% 		%if strcmp(get(handles.gui_handles.OptionsDisplayMotionVectorMenuItem,'Checked'),'on') == 1
% 		if GetMotionDisplaySelection(handles) > 1
% 			handles = guidata(mainfigure);
% 			handles.reg.mvx_pass = Vx;
% 			handles.reg.mvy_pass = Vy;
% 			handles.reg.mvz_pass = Vz;
% 
% 			guidata(mainfigure,handles);
% 			ConditionalRefreshDisplay(handles,1:9);
% 		end
% 		clear handles;
% 	end
	
	clear Vy0 Vx0 Vz0;
	maxv = max(dV(:));
	fprintf('%d: motion mean = %d, max: %d\n',iter,mean(dV(:)), maxv);
	
	% Convergence speed testing with ground truth, for testing purpose
	% Input mvx0,mvy0,mvz0 are the ground truth motion field
	if exist('mvx0','var') && ~isempty(mvx0) && options(3) == 0
		if options(5) == 0
			error_sr = sqrt((mvx0-Vx).^2+(mvy0-Vy).^2+(mvz0-Vz).^2);
			max_errors(iter) = max(error_sr(:));
			mean_errors(iter) = mean(error_sr(:));
		else
			mvyt = Vy/2;
			mvxt = Vx/2;
			mvzt = Vz/2;
% 
% 			[imvy,imvx,imvz]=invert_motion_field(-mvyt,-mvxt,-mvzt);
% 			imvy(isnan(imvy))=0;
% 			imvx(isnan(imvx))=0;
% 			imvz(isnan(imvz))=0;
% 			
% 			mvyt = 2*imvy;
% 			mvxt = 2*imvx;
% 			mvzt = 2*imvz;
% 			
% 			error_sr = sqrt((mvx0-mvxt).^2+(mvy0-mvyt).^2+(mvz0-mvzt).^2);

			erx = mvxt - move3dimage(mvx0/2,mvyt,mvxt,mvzt);
			ery = mvyt - move3dimage(mvy0/2,mvyt,mvxt,mvzt);
			erz = mvzt - move3dimage(mvz0/2,mvyt,mvxt,mvzt);

			error_sr = sqrt(erx.^2+ery.^2+erz.^2)*2;
			if exist('mask0','var') && ~isempty(mask0)
				error_sr = error_sr .* mask0;
			end
			
			max_errors(iter) = max(error_sr(:));
			mean_errors(iter) = mean(error_sr(:));
		end
		max_dvs(iter) = maxv;
		mean_dvs(iter) = mean(dV(:));
		clear error_sr;
	end
	
	if maxv <= stop
		break;
	end
	
	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		break;	% break out off the loop
	end
	
	% For testing, to compute the convergence
	
end

if (~isempty(mainfigure)), set(mainfigure,'Name',figureTitle); drawnow; end

% Convergence speed testing with ground truth, for testing purpose
if exist('mvx0','var') && ~isempty(mvx0) && options(3) == 0
	figure;plot(max_dvs);ylabel('Maximal motion at an iteration');
	figure;plot(mean_dvs);ylabel('Mean motion at an iteration');
	figure;plot(max_errors);ylabel('Maximal error from ground truth at an iteration');
	figure;plot(mean_errors);ylabel('Mean error from ground truth at an iteration');

	varargout{4} = max_dvs;
	varargout{5} = mean_dvs;
	varargout{6} = max_errors;
	varargout{7} = mean_errors;
end

varargout{1} = Vy;
varargout{2} = Vx;
varargout{3} = Vz;


magv = sqrt(Vy.*Vy+Vx.*Vx+Vz.*Vz);
maxv = max(magv(:));
fprintf('After %d iterations, motion mean = %d, max: %d\n',iter, mean(magv(:)), maxv);

return


