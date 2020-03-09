function [mvy,mvx,mvz] = levelset_motion_0(mainfigure,im1,im2,factor,maxiter,stop)
%{
Levelset deformable registration method.

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

dim = size(im1);

% H = waitbar(0,'Levelset motion');
% set(H,'Name','Optical motion');
% set(H,'NumberTitle','off');

mvx = zeros(dim,'single');
mvy = mvx; mvz = mvx;
d_mvx = mvx;
d_mvy = mvx;
d_mvz = mvx;

i1vx = im1;

for iter = 1:maxiter
	if( iter > 1 )
		old_d_mvx = d_mvx;
		old_d_mvy = d_mvy;
		old_d_mvz = d_mvz;
	end

	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing i1vxs ...', iter));
	i1vxs = lowpass3d(i1vx,2);
	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing gradient_ENO_3d ...', iter));
	[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');
	grad = grad + (grad==0);

	F = (im2 - i1vx);
	d_mvx = F .* u ./ grad;
	d_mvy = F .* v ./ grad;
	d_mvz = F .* w ./ grad;

	mmvx = max(abs(d_mvx(:)));
	mmvy = max(abs(d_mvy(:)));
	mmvz = max(abs(d_mvz(:)));
	meanmvx = mean(abs(d_mvx(:)));
	meanmvy = mean(abs(d_mvy(:)));
	meanmvz = mean(abs(d_mvz(:)));
	
	dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt
	if( iter > 2 )
		t1 = sign(old_d_mvx.*d_mvx.*(abs(d_mvx)>meanmvx));
		t2 = sign(old_d_mvy.*d_mvy.*(abs(d_mvy)>meanmvy));
		t3 = sign(old_d_mvz.*d_mvz.*(abs(d_mvz)>meanmvz));
		cond = sum(t1(:)) < -sum(t1(:)~=0) * 0.4 | sum(t2(:)) < - sum(t2(:)~=0)*0.4 | sum(t3(:)) < - sum(t3(:)~=0)*0.4;
		clear t1 t2 t3;

		if( cond )
			%Oscillation is detected
			factor = max(factor/2,1e-2);
% 			if( factor > 2e-2 )
% 				disp(sprintf('Factor is reduced to %d',factor));
% 			end
		end
	end
	clear i1vxs u v w grad F;
	
	d_mvx = d_mvx * dt * factor;
	d_mvy = d_mvy * dt * factor;
	d_mvz = d_mvz * dt * factor;

	mvx = mvx - d_mvx;
	mvy = mvy - d_mvy;
	mvz = mvz - d_mvz;

	mv_diff = sqrt(d_mvx.^2 + d_mvy.^2 + d_mvz.^2);

	maxv=max(mv_diff(:));
	if maxv < stop
		break;
	end
	
	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		break;	% break out off the loop
	end

	fprintf('iter %d: max motion = %d\n', iter, maxv);
	i1vx = move3dimage(im1,mvy,mvx,mvz);
	drawnow;
end

%close(H);


