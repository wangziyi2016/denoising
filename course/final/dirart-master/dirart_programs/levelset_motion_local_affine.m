function [mvy,mvx,mvz]=levelset_motion_local_affine(mainfigure,im1,im2,factor,maxiter,tor,localblocksizes,SplineApprGridSize,LowPassKernalSize,local_adaptive)
%{
Levelset deformable registration method, local affine approximation.

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}
dim = mysize(im1);

%NM = prod(dim);		% total number of pixels

x0 = single(1:dim(2));
y0 = single(1:dim(1));
z0 = single(1:dim(3));
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

%dtr = ceil(dim(1)/localblocksizes(1));dco = ceil(dim(2)/localblocksizes(2));dsa=ceil(dim(3)/localblocksizes(3));	% size of each section
dtr = localblocksizes(1); dco = localblocksizes(2); dsa = localblocksizes(3);
nstr = ceil(dim(1)/dtr);
nsco = ceil(dim(2)/dco);
nssa = ceil(dim(3)/dsa);

if( ~exist('local_adaptive','var') )
	local_adaptive = 1;
end

factors = ones(nstr,nsco,nssa)*factor;

i1vx = im1;
mvx = zeros(dim,'single');
mvy = zeros(dim,'single');
mvz = zeros(dim,'single');

d_mvx = zeros(dim,'single');		% For oscillation detection
d_mvy = zeros(dim,'single');
d_mvz = zeros(dim,'single');

% H = waitbar(0,'Levelset motion');
% set(H,'Name','Optical motion - local affine');
% set(H,'NumberTitle','off');

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

	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing i1vxs ...', iter));
	disp(sprintf('iter %d: Computing i1vxs ...', iter));
	i1vxs = lowpass3d(i1vx,1);
	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing gradient ...', iter));
	disp(sprintf('iter %d: Computing gradient ...', iter));
	%[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');
	[v,u,w] = gradient_3d_by_mask(i1vxs);
	grad = sqrt(u.*u+v.*v+w.*w);

	F = (im2 - i1vx);
	d_mvx = F .* u ./ (grad + (grad==0));
	d_mvy = F .* v ./ (grad + (grad==0));
	d_mvz = F .* w ./ (grad + (grad==0));

	clear u v w grad F;

	% Local affine deformation
	% We will split the image into sections. For each
	% section, we will calculate the local affine transformation on
	% top of the global affine transformation

	d_mvx2 = zeros(dim,'single');
	d_mvy2 = zeros(dim,'single');
	d_mvz2 = zeros(dim,'single');

	warning off;

	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Local affine approximating ...', iter));
	disp(sprintf('iter %d: Local affine approximating ...', iter));
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
				xx2 = xx(tr0:tr1,co0:co1,sa0:sa1);
				yy2 = yy(tr0:tr1,co0:co1,sa0:sa1);
				zz2 = zz(tr0:tr1,co0:co1,sa0:sa1);

				[G,dbx2,dby2,dbz2]=affine_fit_3d(dbx,dby,dbz,xx2,yy2,zz2);
				
				if( local_adaptive == 1 )
					mmvx = max(abs(dbx2(:)));
					mmvy = max(abs(dby2(:)));
					mmvz = max(abs(dbz2(:)));
					if max([mmvx mmvy mmvz]) == 0
						dt = 1;
					else
						dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt
					end
					

					% Oscillation detection
					if( iter > 1 )
						t1 = sign(old_d_mvx(tr0:tr1,co0:co1,sa0:sa1).*dbx.*(abs(dbx2)>mmvx/2));
						t2 = sign(old_d_mvy(tr0:tr1,co0:co1,sa0:sa1).*dby.*(abs(dby2)>mmvy/2));
						t3 = sign(old_d_mvz(tr0:tr1,co0:co1,sa0:sa1).*dbz.*(abs(dbz2)>mmvz/2));
						cond = sum(t1(:)<0) > sum(t1(:)~=0) * 0.5 | sum(t2(:)<0) > sum(t2(:)~=0)*0.5 | sum(t3(:)<0) > sum(t3(:)~=0)*0.5;

						if( cond )
							%Oscillation is detected
							factors(ntr,nco,nsa) = max(factors(ntr,nco,nsa)*0.6,1e-2/dt);
% 							if( factors(ntr,nco,nsa) > 2e-2/dt )
% 								disp(sprintf('Factor (%d,%d,%d) is reduced to %d',ntr,nco,nsa,factors(ntr,nco,nsa)));
% 							end
						end
					end

					d_mvx2(tr0:tr1,co0:co1,sa0:sa1) = dbx2 * dt * factors(ntr,nco,nsa);
					d_mvy2(tr0:tr1,co0:co1,sa0:sa1) = dby2 * dt * factors(ntr,nco,nsa);
					d_mvz2(tr0:tr1,co0:co1,sa0:sa1) = dbz2 * dt * factors(ntr,nco,nsa);
				end
			end
		end
	end

	if( ~isempty(LowPassKernalSize) )
		%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Low pass smoothing motion ...', iter));
		disp(sprintf('iter %d: Low pass smoothing motion ...', iter));
		G = ones(LowPassKernalSize,'single')/prod(LowPassKernalSize);
		d_mvx = lowpass3d(d_mvx2,G);
		d_mvy = lowpass3d(d_mvy2,G);
		d_mvz = lowpass3d(d_mvz2,G);
	else
		d_mvx = d_mvx2;
		d_mvy = d_mvy2;
		d_mvz = d_mvz2;
	end
	
	clear dbx2 dby2 dbz2 d_mvx2 d_mvy2 d_mvz2;
	
	if( ~isempty(SplineApprGridSize) )
		%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Spline approximating ...', iter));
		disp(sprintf('iter %d: Spline approximating ...', iter));
		d_mvx = splinesmooth3d(d_mvx,[9 9 5]);
		d_mvy = splinesmooth3d(d_mvy,[9 9 5]);
	end

	if( local_adaptive ~= 1 )
		mmvx = max(abs(d_mvx(:)));
		mmvy = max(abs(d_mvy(:)));
		mmvz = max(abs(d_mvz(:)));
		dt = 1 / max([mmvx mmvy mmvz]);	% Calculate the safe value of dt

		% Oscillation detection
		if( iter > 1 )
			t1 = sign(old_d_mvx.*d_mvx.*(abs(d_mvx)>mmvx/4));
			t2 = sign(old_d_mvy.*d_mvy.*(abs(d_mvy)>mmvy/4));
			t3 = sign(old_d_mvz.*d_mvz.*(abs(d_mvz)>mmvz/4));
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

		d_mvx = d_mvx * dt * factor;
		d_mvy = d_mvy * dt * factor;
		d_mvz = d_mvz * dt * factor;
	end
	
	mvx = mvx - d_mvx;
	mvy = mvy - d_mvy;
	mvz = mvz - d_mvz;

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
	
	if mrs < tor || max(factors(:)) < 0.1
		break;
	end

	%waitbar((iter-1)/maxiter,H,sprintf('iter %d: Computing i1vx ...', iter));
	fprintf('iter %d: mean motion = %d\n', iter, sqrt(mrs));
	fprintf('iter %d: Computing i1vx\n', iter);
	i1vx = move3dimage(im1,mvy,mvx,mvz);
	
	drawnow;

	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		return;	% break out off the loop
	end
end

%close(H);


