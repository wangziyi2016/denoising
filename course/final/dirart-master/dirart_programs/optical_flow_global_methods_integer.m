function [Vy,Vx,Vz] = optical_flow_global_methods_integer(method,mainfigure,img1,imgt,voxelsizes,maxiter,stop,mvy,mvx,mvz,offsets)
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

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

max_intensity = single(max(max(img1(:)),max(imgt(:))));
mulfac = 100;

if max_intensity < 1
	max_intensity_value = 2000;
	img1 = img1 * max_intensity_value;
	imgt = imgt * max_intensity_value;
end

img1 = int16(img1);
imgt = int16(imgt);

if exist('mvx','var')
	mvx = int16(mvx*mulfac);
	mvy = int16(mvy*mulfac);
	mvz = int16(mvz*mulfac);
end

classname = class(img1);

if ~exist('maxiter','var') || isempty(maxiter)
	maxiter = 20;
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

dim=mysize(imgt);
yoffs = (1:dim(1))+offsets(1);
xoffs = (1:dim(2))+offsets(2);
zoffs = (1:dim(3))+offsets(3);

%Vy = zeros(dim,'single'); Vx=Vy;Vz=Vy;
Vy = zeros(dim,'int16'); Vx=Vy;Vz=Vy;

if ~exist('mvx','var') || isempty(mvx)
	options(3) = 0;	% Disable divergence constraint
end

titles1{1} = 'Original Horn-Schunck';
titles1{2} = 'Horn-Schunck with weighted global smoothness';
titles2{1} = '';
titles2{2} = ' with local LMS';
titles3{1} = '';
titles3{2} = ' and divergence constraint';

windowtitle = [titles1{options(1)+1} titles2{options(2)+1} titles3{options(3)+1}];

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

[Iy,Ix,Iz] = gradient_3d_by_mask(single(img1));
Iy = Iy(yoffs,xoffs,zoffs)*voxelsizes(1);
Ix = Ix(yoffs,xoffs,zoffs)*voxelsizes(2);
Iz = Iz(yoffs,xoffs,zoffs)*voxelsizes(3);

Iy = cast(Iy,classname);
Ix = cast(Ix,classname);
Iz = cast(Iz,classname);

img1 = img1(yoffs,xoffs,zoffs);
It = imgt - img1;

if options(1) == 0	% Original Horn-Schunck method
	% Parameters
	lambda = 0.3*max_intensity;
	fprintf('Lambda = %d\n',lambda);

	suma = lambda*lambda + single(Ix).^2 + single(Iy).^2 + single(Iz).^2;
else % Issam's modification - weighted smoothness
	% Parameters
	T = 0.05*max_intensity;
	lambda0 = 0.5*max_intensity;
	fprintf('T = %d, Lambda0 = %d\n',T,lambda0);

	sgrad=sqrt(single(Ix).^2+single(Iy).^2+single(Iz).^2);
	sgrad = sgrad / max(sgrad(:));

	lambda1=lambda0/2*(1+exp(-sgrad/T));
	% initialize params...
	lambda2=lambda1.*lambda1;
	suma = lambda2+single(Ix).^2+single(Iy).^2+single(Iz).^2;
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
	IyIy = conv3fft(Iy.*Iy,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iy*Ix ...']); drawnow; end
	IyIx = conv3fft(Iy.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iy*Iz ...']); drawnow; end
	IyIz = conv3fft(Iy.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Ix*Ix ...']); drawnow; end
	IxIx = conv3fft(Ix.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Ix*Iz ...']); drawnow; end
	IxIz = conv3fft(Ix.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing Iz*Iz ...']); drawnow; end
	IzIz = conv3fft(Iz.*Iz,W2);

	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Iy ...']); drawnow; end
	ItIy = conv3fft(It.*Iy,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Ix ...']); drawnow; end
	ItIx = conv3fft(It.*Ix,W2);
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle ' Smoothing It*Iz ...']); drawnow; end
	ItIz = conv3fft(It.*Iz,W2);
else
	ItIy = single(It).*single(Iy);
	ItIx = single(It).*single(Ix);
	ItIz = single(It).*single(Iz);
end

if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s',windowtitle)]); drawnow; end

max_motion_per_iteration = 0.5;
%max_motion_per_iteration = 0.5;

for i=1:maxiter
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('Optical Flow - %s - Iter %d off %d',windowtitle,i,maxiter)]); drawnow; end
	[Vya,Vxa,Vza]=hs_velocity_avg3d(Vy,Vx,Vz);
	
	Vy0 = Vy; Vx0 = Vx; Vz0 = Vz;
	
	if length(options) >= 3 && options(3) == 1	
		% Divergence constraint
		lambda2 = 0.005*max_intensity;

		Vyy =					gradient_3d_by_mask(mvy+Vy);
		[dummy1,Vxx] =			gradient_3d_by_mask(mvx+Vx);
		[dummy1,dummy2,Vzz] =	gradient_3d_by_mask(mvz+Vz);
		clear dummy1 dummy2;
		
		[Vyyy,Vyyx,Vyyz] = gradient_3d_by_mask(single(Vyy));
		ItIy2 = ItIy - lambda2*Vyyy; clear Vyyy;
		ItIx2 = ItIx - lambda2*Vyyx; clear Vyyx;
		ItIz2 = ItIz - lambda2*Vyyz; clear Vyyz;
		clear Vyy;
		
		[Vxxy,Vxxx,Vxxz] = gradient_3d_by_mask(single(Vxx));
		ItIy2 = ItIy2 - lambda2*Vxxy; clear Vxxy;
		ItIx2 = ItIx2 - lambda2*Vxxx; clear Vxxx;
		ItIz2 = ItIz2 - lambda2*Vxxz; clear Vxxz;
		clear Vxx;
		
		[Vzzy,Vzzx,Vzzz] = gradient_3d_by_mask(single(Vzz));
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
		Vy = Vya - 10*(Vya.*IyIy + Vxa.*IyIx + Vza.*IyIz + ItIy2) ./ suma;
		Vx = Vxa - 10*(Vya.*IyIx + Vxa.*IxIx + Vza.*IxIz + ItIx2) ./ suma;
		Vz = Vza - 10*(Vya.*IyIz + Vxa.*IxIz + Vza.*IzIz + ItIz2) ./ suma;
	else
		sumb = single(Iy).*single(Vya)/mulfac + single(Ix).*single(Vxa)/mulfac + single(Iz).*single(Vza)/mulfac;
		Vy = Vya-int16(((single(Iy).*sumb+ItIy2)./suma)*mulfac);
		Vx = Vxa-int16(((single(Ix).*sumb+ItIx2)./suma)*mulfac);
		Vz = Vza-int16(((single(Iz).*sumb+ItIz2)./suma)*mulfac);
		clear sumb;
	end
	clear ItIy2 ItIx2 ItIz2;
	
	
	% Limit the motion field update per iteration
	dV = sqrt(abs(single(Vy0 - Vy)).^2 + abs(single(Vx0-Vx)).^2 + abs(single(Vz0-Vz)).^2);
	if max(dV(:)) > max_motion_per_iteration*mulfac
		dVy = Vy - Vy0;
		dVx = Vx - Vx0;
		dVz = Vz - Vz0;
		idxes = find( dV > max_motion_per_iteration );
		dVy(idxes) = int16(single(dVy(idxes)) * max_motion_per_iteration * mulfac ./ dV(idxes));
		dVx(idxes) = int16(single(dVx(idxes)) * max_motion_per_iteration * mulfac ./ dV(idxes));
		dVz(idxes) = int16(single(dVz(idxes)) * max_motion_per_iteration * mulfac ./ dV(idxes));
		Vy(idxes) = Vy0(idxes)+int16(dVy(idxes));
		Vx(idxes) = Vx0(idxes)+int16(dVx(idxes));
		Vz(idxes) = Vz0(idxes)+int16(dVz(idxes));
		dV(idxes) = max_motion_per_iteration*mulfac;
		clear dVy dVx dVz idxes;
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
	
	clear Vy0 Vx0 Vz0;
	maxv = max(dV(:));
	fprintf('Iteration %d: max movement: %d\n',i,maxv);
	
	if maxv <= stop*mulfac
		break;
	end
	
	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		break;;	% break out off the loop
	end
end

Vy = single(Vy)/mulfac;
Vx = single(Vx)/mulfac;
Vz = single(Vz)/mulfac;

if (~isempty(mainfigure)), set(mainfigure,'Name',figureTitle); drawnow; end

return


