function [mvy,mvx,mvz] = levelset_motion_free_deform_wo_gui(im1,im2,factor,maxiter,tor,SplineApprGridSize,LowPassKernalSize,boundary,local_adaptive)
%{
Levelset deformable registration method, free deformation, without GUI.

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

if( ~exist('boundary','var') )
	boundary = 0;
end

if( ~exist('local_adaptive','var') )
	local_adaptive = 1;
end

dim = size(im1);

% H = waitbar(0,'Levelset motion');
% set(H,'Name','Optical motion');
% set(H,'NumberTitle','off');

if( local_adaptive == 1 )
	nstr = ceil(dim(1)/8);
	nsco = ceil(dim(2)/8);
	nssa = ceil(dim(3)/8);
	dtr = ceil(dim(1)/nstr);dco = ceil(dim(2)/nsco);dsa=ceil(dim(3)/nssa);	% size of each section
	factors = ones(nstr,nsco,nssa)*factor;
end

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
	disp(sprintf('iter %d: Computing i1vxs ...', iter));
	i1vxs = lowpass3d(i1vx,1);
	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing gradient ...', iter));
	disp(sprintf('iter %d: Computing gradient ...', iter));
	%[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');
	%[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');
	[u,v,w] = gradient_3d_by_mask(i1vxs);
	grad = sqrt(u.*u+v.*v+w.*w);

	grad = grad + (grad==0);

	F = (im2 - i1vx);
	d_mvx = F .* u ./ grad;
	d_mvy = F .* v ./ grad;
	d_mvz = F .* w ./ grad;
	
	clear i1vxs u v w grad F;
	
	if( local_adaptive == 1 )
		%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing factors ...', iter));
		disp(sprintf('iter %d: Computing factors ...', iter));
		for ntr = 1:nstr
			for nco = 1:nsco
				for nsa = 1:nssa
					%[nstr nsco nssa ntr nco nsa]
					tr0 = (ntr-1)*dtr+1;
					tr1 = min(ntr*dtr,dim(1));
					co0 = (nco-1)*dco+1;
					co1 = min(nco*dco,dim(2));
					sa0 = (nsa-1)*dsa+1;
					sa1 = min(nsa*dsa,dim(3));
					%[tr0 tr1 co0 co1 sa0 sa1]

					dbx = d_mvx(tr0:tr1,co0:co1,sa0:sa1);
					dby = d_mvy(tr0:tr1,co0:co1,sa0:sa1);
					dbz = d_mvz(tr0:tr1,co0:co1,sa0:sa1);

					mmvx = max(abs(dbx(:)));
					mmvy = max(abs(dby(:)));
					mmvz = max(abs(dbz(:)));
					if max([mmvx mmvy mmvz]) ~= 0
						dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt
					else
						dt = 1;
					end

					% Oscillation detection
					if( iter > 1 )
						t1 = sign(old_d_mvx(tr0:tr1,co0:co1,sa0:sa1).*dbx.*(abs(dbx)>mmvx/2));
						t2 = sign(old_d_mvy(tr0:tr1,co0:co1,sa0:sa1).*dby.*(abs(dby)>mmvy/2));
						t3 = sign(old_d_mvz(tr0:tr1,co0:co1,sa0:sa1).*dbz.*(abs(dbz)>mmvz/2));
						cond = sum(t1(:)<0) > sum(t1(:)~=0) * 0.5 | sum(t2(:)<0) > sum(t2(:)~=0)*0.5 | sum(t3(:)<0) > sum(t3(:)~=0)*0.5;

						if( cond )
							%Oscillation is detected
							factors(ntr,nco,nsa) = max(factors(ntr,nco,nsa)*0.6,1e-2/dt);
% 							if( factors(ntr,nco,nsa) > 2e-2/dt )
% 								disp(sprintf('Factor (%d,%d,%d) is reduced to %d',ntr,nco,nsa,factors(ntr,nco,nsa)));
% 							end
						end
					end

					d_mvx(tr0:tr1,co0:co1,sa0:sa1) = dbx * dt * factors(ntr,nco,nsa);
					d_mvy(tr0:tr1,co0:co1,sa0:sa1) = dby * dt * factors(ntr,nco,nsa);
					d_mvz(tr0:tr1,co0:co1,sa0:sa1) = dbz * dt * factors(ntr,nco,nsa);
				end
			end
		end
	end
	
	if ~isempty(LowPassKernalSize)
		%waitbar((iter-1)/maxiter,H,sprintf('iter %d: low pass smoothing motion ...', iter));
		disp(sprintf('iter %d: low pass smoothing motion ...', iter));
		G = ones(LowPassKernalSize,'single')/prod(LowPassKernalSize);
		d_mvx = lowpass3d(d_mvx,1);
		d_mvy = lowpass3d(d_mvy,1);
		d_mvz = lowpass3d(d_mvz,1);
	end	
	
	if ~isempty(SplineApprGridSize)
		%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Spline approximating ...', iter));
		disp(sprintf('iter %d: Spline approximating ...', iter));
		d_mvx = splinesmooth3d(d_mvx,SplineApprGridSize);
		d_mvy = splinesmooth3d(d_mvy,SplineApprGridSize);
		d_mvz = splinesmooth3d(d_mvz,SplineApprGridSize);
	end


	if( local_adaptive ~= 1 )
		d1c = [1+boundary:dim(1)-boundary];
		d2c = [1+boundary:dim(2)-boundary];
		d3c = [1+boundary:dim(3)-boundary];
		mmvx = max(max(max(abs(d_mvx(d1c,d2c,d3c)))));
		mmvy = max(max(max(abs(d_mvy(d1c,d2c,d3c)))));
		mmvz = max(max(max(abs(d_mvz(d1c,d2c,d3c)))));
		meanmvx = mean(mean(mean(abs(d_mvx(d1c,d2c,d3c)))));
		meanmvy = mean(mean(mean(abs(d_mvy(d1c,d2c,d3c)))));
		meanmvz = mean(mean(mean(abs(d_mvz(d1c,d2c,d3c)))));

		% 	mmvx = max(abs(d_mvx(:)));
		% 	mmvy = max(abs(d_mvy(:)));
		% 	mmvz = max(abs(d_mvz(:)));
		dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt

		% Oscillation detection

		if( iter > 1 )
			% 		if( step == 3 )
			t1 = sign(old_d_mvx(d1c,d2c,d3c).*d_mvx(d1c,d2c,d3c).*(abs(d_mvx(d1c,d2c,d3c))>mmvx/4));
			t2 = sign(old_d_mvy(d1c,d2c,d3c).*d_mvy(d1c,d2c,d3c).*(abs(d_mvy(d1c,d2c,d3c))>mmvy/4));
			t3 = sign(old_d_mvz(d1c,d2c,d3c).*d_mvz(d1c,d2c,d3c).*(abs(d_mvz(d1c,d2c,d3c))>mmvz/4));
			cond = sum(t1(:)<0) > sum(t1(:)~=0) * 0.5 | sum(t2(:)<0) > sum(t2(:)~=0)*0.5 | sum(t3(:)<0) > sum(t3(:)~=0)*0.5;

			clear t1 t2 t3;

			if( cond )
				%Oscillation is detected
				factor = max(factor*0.6,1e-2);
				if( factor > 2e-2 )
					disp(sprintf('Factor is reduced to %d',factor));
				end
			end
		end

		disp(sprintf('Max: [%.5f, %.5f, %.5f]\nMean: [%.5f, %.5f, %.5f]\ndt = %.5f, factor = %.5f\n',mmvy,mmvx,mmvz,meanmvy, meanmvx, meanmvz,dt,factor));

		mvx = mvx - d_mvx * dt * factor;
		mvy = mvy - d_mvy * dt * factor;
		mvz = mvz - d_mvz * dt * factor;

		mv_diff = (d_mvx(d1c,d2c,d3c) * dt * factor).^2 + (d_mvy(d1c,d2c,d3c) * dt * factor).^2 + (d_mvz(d1c,d2c,d3c) * dt * factor).^2;
	else
		mvx = mvx - d_mvx;
		mvy = mvy - d_mvy;
		mvz = mvz - d_mvz;

		mv_diff = d_mvx.^2 + d_mvy.^2 + d_mvz.^2;
	end
	
	mrs=mean(mv_diff(:));
	clear mv_diff;
	pause(0.01);

	if mrs < tor || max(factors(:)) < 0.1
		break;
	end

	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing i1vx ...', iter));
	disp(sprintf('iter %d: mrs = %d ...', iter, mrs));
	disp(sprintf('iter %d: Computing i1vx ...', iter));
	i1vx = move3dimage(im1,mvy,mvx,mvz);
	
	drawnow;
end

%close(H);



