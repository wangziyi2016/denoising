function [mvy,mvx,mvz] = levelset_motion_global_affine_wo_gui(im1,im2,factor,maxiter,tor)
%{
Levelset deformable registration method, global affine approximation, without GUI.

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

dim = size(im1);
mvx = zeros(dim,'single');
mvy = zeros(dim,'single');
mvz = zeros(dim,'single');

d_mvx = zeros(dim,'single');
d_mvy = zeros(dim,'single');
d_mvz = zeros(dim,'single');

i1vx = im1;

for iter = 1:maxiter
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

	mvx = mvx - d_mvx * dt * factor;
	mvy = mvy - d_mvy * dt * factor;
	mvz = mvz - d_mvz * dt * factor;

	i1vx = move3dimage(im1,mvy,mvx,mvz);

	mv_diff = (d_mvx * dt * factor).^2 + (d_mvy * dt * factor).^2 + (d_mvz * dt * factor).^2;
	mrs=mean(mv_diff(:));
	clear mv_diff;

	if mrs < tor
		break;
	end
	
	disp(sprintf('iter %d: mrs = %d ...', iter, mrs));
	
	drawnow;

end

