function [mvy,mvx,mvz] = levelset_motion_global_affine(mainfigure,im1,im2,factor,maxiter,tor)
%{
Levelset deformable registration method, global affine approximation.

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

dim = size(im1);
if ndims(im1) == 2
	dim(3) = 1;
end

mvx = zeros(dim,'single');
mvy = zeros(dim,'single');
mvz = zeros(dim,'single');

d_mvx = zeros(dim,'single');
d_mvy = zeros(dim,'single');
d_mvz = zeros(dim,'single');

i1vx = im1;

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

for iter = 1:maxiter
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle sprintf(' - iteration %d',iter)]);
		drawnow;
	end

	if( iter > 1 )
		old_d_mvx = d_mvx;
		old_d_mvy = d_mvy;
		old_d_mvz = d_mvz;
	end

	i1vxs = lowpass3d(i1vx,1);
	disp(sprintf('iter %d: Computing gradient ...', iter));
	%[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');
	[v,u,w] = gradient_3d_by_mask(i1vxs);
	grad = sqrt(u.*u+v.*v+w.*w);

	F = im2 - i1vx;
	d_mvx = F .* u ./ (grad + (grad==0));
	d_mvy = F .* v ./ (grad + (grad==0));
	d_mvz = F .* w ./ (grad + (grad==0));

	[G,d_mvx,d_mvy,d_mvz]=affine_fit_3d(d_mvx,d_mvy,d_mvz);

	mmvx = max(abs(d_mvx(:)));
	mmvy = max(abs(d_mvy(:)));
	mmvz = max(abs(d_mvz(:)));
	
	dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt

	% Oscillation detection
	if( iter > 2 )
		t1 = sign(old_d_mvx.*d_mvx.*(abs(d_mvx)>mmvx/4));
		t2 = sign(old_d_mvy.*d_mvy.*(abs(d_mvy)>mmvy/4));
		t3 = sign(old_d_mvz.*d_mvz.*(abs(d_mvz)>mmvz/4));
		cond = sum(t1(:)<0) > sum(t1(:)~=0) * 0.5 | sum(t2(:)<0) > sum(t2(:)~=0)*0.5 | sum(t3(:)<0) > sum(t3(:)~=0)*0.5;

		clear t1 t2 t3;

		if( cond )
			%Oscillation is detected
			factor = max(factor*0.6,1e-2);
		end
	end

	d_mvx = d_mvx * dt * factor;
	d_mvy = d_mvy * dt * factor;
	d_mvz = d_mvz * dt * factor;

	mvx = mvx - d_mvx;
	mvy = mvy - d_mvy;
	mvz = mvz - d_mvz;

	i1vx = move3dimage(im1,mvy,mvx,mvz);
	
	% Update display
	if ~isempty(mainfigure)
		handles = guidata(mainfigure);
		if GetMotionDisplaySelection(handles) > 1
			handles = guidata(mainfigure);
			handles.images(1).image_deformed = i1vx;
			handles.reg.mvx_iteration = -d_mvx;
			handles.reg.mvy_iteration = -d_mvy;
			handles.reg.mvz_iteration = -d_mvz;
			handles.reg.mvx_pass = mvx;
			handles.reg.mvy_pass = mvy;
			handles.reg.mvz_pass = mvz;

			guidata(mainfigure,handles);
			ConditionalRefreshDisplay(handles,1:9);
		end
		clear handles;
	end

	mv_diff = d_mvx.^2 + d_mvy.^2 + d_mvz.^2;
	mrs=mean(mv_diff(:));
	clear mv_diff;

	if mrs < tor
		break;
	end
	
	disp(sprintf('iter %d: mrs = %d ...', iter, mrs));
	
	drawnow;

	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		return;	% break out off the loop
	end
end

