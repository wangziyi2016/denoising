function [Vy1,Vx1,Vz1,Vy2,Vx2,Vz2] = optical_flow_inverse_consistency_methods(method,mainfigure,img1,img2,voxelsizes,maxiter,stop)
%
% Gloabl optical flow inverse consistency methods
%
% [Vy,Vx,Vz] = optical_flow_inverse_consistency_methods(method,mainfigure,img1,img2,voxelsizes,maxiter,stop)
%
% Implemented by: Deshan Yang, 01/2007
%
% Input parameters:
% img1	-	Image to be registered
% img2	-	The target image (the reference)
% method	-	1 - original Horn-Schunck method
%				2 - HS + intensity correction
% Outputs:
% u,v,w	-	The motion fields
%
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

max_intensity = max(max(img1(:)),max(img2(:)));

haveNaNs = (sum(isnan(img1(:)))+sum(isnan(img2(:))) > 0);


if ~exist('maxiter','var') || isempty(maxiter)
	maxiter = 20;
end

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

if ~exist('mainfigure','var')
	mainfigure = [];
end

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end


if length(voxelsizes) == 1
	voxelsizes = [1 1 voxelsizes];
end

dim=mysize(img2);

Vy1 = zeros(dim,'single'); Vx1=Vy1;Vz1=Vy1;
Vy2 = Vy1; Vx2 = Vy1; Vz2 = Vy1;	% Motion field for image #2

windowtitle = 'Reverse consistent Horn-Schunck optical flow method';

[Iy1,Ix1,Iz1] = gradient_3d_by_mask(single(img1));
Iy1 = Iy1*voxelsizes(1);
Ix1 = Ix1*voxelsizes(2);
Iz1 = Iz1*voxelsizes(3);
% if haveNaNs
% 	Iy1(isnan(Iy1)) = 0;
% 	Ix1(isnan(Ix1)) = 0;
% 	Iz1(isnan(Iz1)) = 0;
% end

[Iy2,Ix2,Iz2] = gradient_3d_by_mask(single(img2));
Iy2 = Iy2*voxelsizes(1);
Ix2 = Ix2*voxelsizes(2);
Iz2 = Iz2*voxelsizes(3);
% if haveNaNs
% 	Iy2(isnan(Iy2)) = 0;
% 	Ix2(isnan(Ix2)) = 0;
% 	Iz2(isnan(Iz2)) = 0;
% end

It1 = single(img2) - single(img1);
% if haveNaNs
% 	It1(isnan(It1)) = 0;
% end
It2 = -It1;

% Parameters
alpha = 0.2*max_intensity; alpha2 = alpha^2;
beta = 0.3*max_intensity; beta2 = beta^2;
gamma2 = alpha2+beta2;

disp(sprintf('alpha = %d, beta = %d',alpha, beta));

suma1 = gamma2 + Ix1.*Ix1 + Iy1.*Iy1 + Iz1.*Iz1;
suma2 = gamma2 + Ix2.*Ix2 + Iy2.*Iy2 + Iz2.*Iz2;

It1Iy1 = It1.*Iy1;
It1Ix1 = It1.*Ix1;
It1Iz1 = It1.*Iz1;

It2Iy2 = It2.*Iy2;
It2Ix2 = It2.*Ix2;
It2Iz2 = It2.*Iz2;
% end

if (~isempty(mainfigure)), set(mainfigure,'Name',windowtitle); end

max_motion_per_iteration = 0.5;

for iter=1:maxiter
	if (~isempty(mainfigure)), set(mainfigure,'Name',[figureTitle sprintf('- %s - Iternation %d off %d',windowtitle,iter,maxiter)]); drawnow; end
	
	[Vy1a,Vx1a,Vz1a]=hs_velocity_avg3d(Vy1,Vx1,Vz1);
	[Vy2a,Vx2a,Vz2a]=hs_velocity_avg3d(Vy2,Vx2,Vz2);
	
	Vy1an = (alpha2*Vy1a - beta2*Vy2) / gamma2;
	Vx1an = (alpha2*Vx1a - beta2*Vx2) / gamma2;
	Vz1an = (alpha2*Vz1a - beta2*Vz2) / gamma2;

	Vy2an = (alpha2*Vy2a - beta2*Vy1) / gamma2;
	Vx2an = (alpha2*Vx2a - beta2*Vx1) / gamma2;
	Vz2an = (alpha2*Vz2a - beta2*Vz1) / gamma2;
	
	Vy10 = Vy1; Vx10 = Vx1; Vz10 = Vz1;
	Vy20 = Vy2; Vx20 = Vx2; Vz20 = Vz2;
	
	sumb1 = Iy1.*Vy1an + Ix1.*Vx1an + Iz1.*Vz1an;
	sumb2 = Iy2.*Vy2an + Ix2.*Vx2an + Iz2.*Vz2an;

	if ~haveNaNs
		Vy1 = Vy1an-(Iy1.*sumb1+It1Iy1)./suma1;
		Vx1 = Vx1an-(Ix1.*sumb1+It1Ix1)./suma1;
		Vz1 = Vz1an-(Iz1.*sumb1+It1Iz1)./suma1;
	else
		temp = (Iy1.*sumb1+It1Iy1)./suma1;
		temp(isnan(temp)) = 0;
		Vy1 = Vy1an-temp;
		
		temp = (Ix1.*sumb1+It1Ix1)./suma1;
		temp(isnan(temp)) = 0;
		Vx1 = Vx1an-temp;
		
		temp = (Iz1.*sumb1+It1Iz1)./suma1;
		temp(isnan(temp)) = 0;
		Vz1 = Vz1an-temp;
		
		clear temp;
	end

	if ~haveNaNs
		Vy2 = Vy2an-(Iy2.*sumb2+It2Iy2)./suma2;
		Vx2 = Vx2an-(Ix2.*sumb2+It2Ix2)./suma2;
		Vz2 = Vz2an-(Iz2.*sumb2+It2Iz2)./suma2;
	else
		temp = (Iy2.*sumb2+It2Iy2)./suma2;
		temp(isnan(temp)) = 0;
		Vy2 = Vy2an-temp;

		temp = (Ix2.*sumb2+It2Ix2)./suma2;
		temp(isnan(temp)) = 0;
		Vx2 = Vx2an-temp;

		temp = (Iz2.*sumb2+It2Iz2)./suma2;
		temp(isnan(temp)) = 0;
		Vz2 = Vz2an-temp;

		clear temp;
	end
	
	dV1 = sqrt(abs(Vy10 - Vy1).^2 + abs(Vx10-Vx1).^2 + abs(Vz10-Vz1).^2);

	if max(dV1(:)) > max_motion_per_iteration
		idxes = find( dV1 > max_motion_per_iteration );
		dVy = Vy1(idxes) - Vy10(idxes);
		dVx = Vx1(idxes) - Vx10(idxes);
		dVz = Vz1(idxes) - Vz10(idxes);
		dVy = dVy * max_motion_per_iteration ./ dV1(idxes);
		dVx = dVx * max_motion_per_iteration ./ dV1(idxes);
		dVz = dVz * max_motion_per_iteration ./ dV1(idxes);
		Vy1(idxes) = Vy10(idxes)+dVy;
		Vx1(idxes) = Vx10(idxes)+dVx;
		Vz1(idxes) = Vz10(idxes)+dVz;
		dV1(idxes) = max_motion_per_iteration;
		clear dVy dVx dVz idxes;
	end
	maxv1 = max(dV1(:));
	clear Vy10 Vx10 Vz10;
	clear dV1;

	dV2 = sqrt(abs(Vy20 - Vy2).^2 + abs(Vx20-Vx2).^2 + abs(Vz20-Vz2).^2);

	if max(dV2(:)) > max_motion_per_iteration
		idxes = find( dV2 > max_motion_per_iteration );
		dVy = Vy2(idxes) - Vy20(idxes);
		dVx = Vx2(idxes) - Vx20(idxes);
		dVz = Vz2(idxes) - Vz20(idxes);
		dVy = dVy * max_motion_per_iteration ./ dV2(idxes);
		dVx = dVx * max_motion_per_iteration ./ dV2(idxes);
		dVz = dVz * max_motion_per_iteration ./ dV2(idxes);
		Vy2(idxes) = Vy20(idxes)+dVy;
		Vx2(idxes) = Vx20(idxes)+dVx;
		Vz2(idxes) = Vz20(idxes)+dVz;
		dV2(idxes) = max_motion_per_iteration;
		clear dVy dVx dVz idxes;
	end
	maxv2 = max(dV2(:));
	clear Vy20 Vx20 Vz20;
	clear dV2;

	maxv = max(maxv1,maxv2);
	
	disp(sprintf('Iteration %d: max movement: %d',iter,maxv));
	
	if( ~isempty(mainfigure) )
		UpdateGUI(mainfigure,Vy1,Vx1,Vz1,Vy2,Vx2,Vz2);
		abortflag = CheckAbortPauseButtons(mainfigure,0);
		if abortflag > 0
			break;
		end
	end
	
	if maxv1 < stop && iter > 3
		break;
	end
end

return;


function UpdateGUI(mainfigure,Vy1,Vx1,Vz1,Vy2,Vx2,Vz2)
if( ~isempty(mainfigure) )
	handles = guidata(mainfigure);
	handles.reg.mvy_iteration = Vy2;
	handles.reg.mvx_iteration = Vx2;
	handles.reg.mvz_iteration = Vz2;
	handles.reg.mvy_pass = Vy1;
	handles.reg.mvx_pass = Vx1;
	handles.reg.mvz_pass = Vz1;
	guidata(mainfigure,handles);
	
	%if strcmp(get(handles.gui_handles.OptionsDisplayMotionVectorMenuItem,'Checked'),'on') == 1
	if GetMotionDisplaySelection(handles) > 1
		h = gcf;
		figure(handles.gui_handles.figure1);
		for k = 1:7
			update_display(handles,k);
		end
		figure(h);
	end
	drawnow;
	
	clear handles;
	
end
return;

