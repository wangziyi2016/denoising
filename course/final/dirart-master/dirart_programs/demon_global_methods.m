function varargout = demon_global_methods(method,mainfigure,im1,im2,voxelsizes,maxiter,stop,LowPassKernalSize,offsets,mvy0,mvx0,mvz0,mask0)
%{
This is the main function of the demons deformable registration algorithm.

[mvy,mvx,mvz] = demon_global_methods(method,mainfigure,im1,im2,voxelsizes,maxiter=20,stop=1e-2,LowPassKernalSize=2,offsets=[0 0 0])

Method =	1:	Original demon method
			2:	modified demon method
			3:	SSD Minimization method
			4:	Iterative optical flow method
			5:	Levelset motion method



Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}


%Check the input parameters

if ~exist('LowPassKernalSize','var') || isempty(LowPassKernalSize)
	LowPassKernalSize = 1;
end

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

if ~exist('maxiter','var') || isempty(maxiter)
	maxiter = 20;
end

if ~exist('offsets','var') || isempty(offsets)
	offsets = [0 0 0];
elseif length(offsets) == 1
	offsets = [0 0 offsets];
end

if ~exist('voxelsizes','var') || isempty(voxelsizes)
	voxelsizes = [1 1 1];
elseif length(voxelsizes) == 1
	voxelsizes = [1 1 voxelsizes];
end

if method > 10
	method = method - 10;
	reverse_consistent = 1;
else
	reverse_consistent = 0;
end

% reverse_consistent = 1;

% Initialization
dim2 = mysize(im2);
dim1 = mysize(im1);
yoffs = (1:dim2(1))+offsets(1);
xoffs = (1:dim2(2))+offsets(2);
zoffs = (1:dim2(3))+offsets(3);

mvx = zeros(dim2,'single'); mvy = mvx; mvz = mvx;

i1vx1 = im1;
i1vx = 	i1vx1(yoffs,xoffs,zoffs);
i2vx = im2;
i2vx1 = i2vx;

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

factors = ones(size(im2),'single');

% Gradient of the target image
im2s = lowpass3d(im2,2);
[v2,u2,w2] = gradient_3d_by_mask(im2s);
v2(isnan(v2))=0;
u2(isnan(u2))=0;
w2(isnan(w2))=0;

grad2 = sqrt(v2.*v2+u2.*u2+w2.*w2);


% Iterations
for iter = 1:maxiter
	if ~isempty(mainfigure) && maxiter > 1
		set(mainfigure,'Name',[figureTitle sprintf(' - iteration %d (%d)',iter,maxiter)]);
		drawnow;
	end

	if reverse_consistent == 1 || method > 1
		fprintf('iter %d (%d): Computing i1vxs', iter, maxiter);
		i1vxs = lowpass3d(i1vx1,0.5);
		fprintf(',gradient');
		[v1,u1,w1] = gradient_3d_by_mask(i1vxs);

		v1 = v1(yoffs,xoffs,zoffs)*voxelsizes(1);
		u1 = u1(yoffs,xoffs,zoffs)*voxelsizes(2);
		w1 = w1(yoffs,xoffs,zoffs)*voxelsizes(3);
		
		v1(isnan(v1))=0;
		u1(isnan(u1))=0;
		w1(isnan(w1))=0;

		grad1 = sqrt(u1.*u1+v1.*v1+w1.*w1);
	end

	if reverse_consistent == 1
		fprintf(',i2vxs');
		%i2vxs = lowpass3d(i2vx1,2);
		i2vxs = i2vx;

		fprintf(',gradient');

		[v2,u2,w2] = gradient_3d_by_mask(i2vxs);
% 		v2(isnan(v2))=0;
% 		u2(isnan(u2))=0;
% 		w2(isnan(w2))=0;

		v2 = v2*voxelsizes(1);
		u2 = u2*voxelsizes(2);
		w2 = w2*voxelsizes(3);
		
		v1 = (v1+v2); v2 = v1;
		u1 = (u1+u2); u2 = u1;
		w1 = (w1+w2); w2 = w1;
		
		grad1 = sqrt(u1.*u1+v1.*v1+w1.*w1);
		grad2 = grad1;
	end
	fprintf('\n');
	
	diff = (i2vx - i1vx);
% 	diff(isnan(diff)) = 0;	% check NaN
	
	switch method
		case 1	% Original demons method
			temp1 = grad2.*grad2 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1==0));
			d_mvy = temp1 .* v2;
			d_mvx = temp1 .* u2;
			d_mvz = temp1 .* w2;
		case 2	% Modified demons method
			temp1 = grad1.*grad1 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1==0));
			d_mvy = temp1 .* v1;
			d_mvx = temp1 .* u1;
			d_mvz = temp1 .* w1;
		case 3	% SSD Minimization method
			alpha = 1;
			d_mvy = diff .* v1 * alpha;
			d_mvx = diff .* u1 * alpha;
			d_mvz = diff .* w1 * alpha;
		case 4	% Iterative optical flow method
			temp1 = grad1.*grad1 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1==0));
			d_mvy = temp1 .* v1;
			d_mvx = temp1 .* u1;
			d_mvz = temp1 .* w1;
		case 5	% Levelset motion method
			grad1 = grad1 + (grad1==0);
			d_mvy = diff .* v1 ./ grad1;
			d_mvx = diff .* u1 ./ grad1;
			d_mvz = diff .* w1 ./ grad1;
		case 6	% Symmetric force demons method
			vt = (v1+v2);
			ut = (u1+u2);
			wt = (w1+w2);
			gradt2 = ut.^2+vt.^2+wt.^2;
			temp1 = gradt2 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1==0));
			d_mvy = temp1 .* vt / 2;
			d_mvx = temp1 .* ut / 2;
			d_mvz = temp1 .* wt / 2;
			clear ut vt wt gradt2;
		case 7	% double force demons method
			temp2 = grad2.*grad2 + diff.*diff;
			temp2 = diff ./ (temp2 + (temp2==0));

			temp1 = grad1.*grad1 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1==0));
			
			d_mvy = temp2 .* v2 + temp1 .* v1;
			d_mvx = temp2 .* u2 + temp1 .* u1;
			d_mvz = temp2 .* w2 + temp1 .* w1;
	end

	old_mvx = mvx;
	old_mvy = mvy;
	old_mvz = mvz;

	d_mvx(isnan(d_mvx)) = 0;	% clear out nan
	d_mvy(isnan(d_mvy)) = 0;
	d_mvz(isnan(d_mvz)) = 0;
	
	d_mvx = -d_mvx.*factors;
	d_mvy = -d_mvy.*factors;
	d_mvz = -d_mvz.*factors;
	
	if LowPassKernalSize > 0 
		fprintf('Smoothing delta motion fields\n');
		% 	d_mvx = lowpass3d_smooth_weighted(d_mvx,LowPassKernalSize,1,abs(u1));
		% 	d_mvy = lowpass3d_smooth_weighted(d_mvy,LowPassKernalSize,1,abs(v1));
		% 	d_mvz = lowpass3d_smooth_weighted(d_mvz,LowPassKernalSize,1,abs(w1));
		d_mvx = lowpass3d(d_mvx,LowPassKernalSize);
		d_mvy = lowpass3d(d_mvy,LowPassKernalSize);
		d_mvz = lowpass3d(d_mvz,LowPassKernalSize);
	end
	
	clear i1vxs u1 v1 w1 grad1 diff;
	
% 	mvx = mvx + d_mvx;
% 	mvy = mvy + d_mvy;
% 	mvz = mvz + d_mvz;

	if iter > 1
		fprintf('Connecting previous fields\n');
		mvy = move3dimage(mvy,d_mvy,d_mvx,d_mvz,'linear') + d_mvy;
		mvx = move3dimage(mvx,d_mvy,d_mvx,d_mvz,'linear') + d_mvx;
		mvz = move3dimage(mvz,d_mvy,d_mvx,d_mvz,'linear') + d_mvz;
	else
		mvx = d_mvx;
		mvy = d_mvy;
		mvz = d_mvz;
	end
	
	if LowPassKernalSize > 0
		fprintf('Smoothing overall motion fields\n');
		mvx = lowpass3d(mvx,LowPassKernalSize);
		mvy = lowpass3d(mvy,LowPassKernalSize);
		mvz = lowpass3d(mvz,LowPassKernalSize);
		% 	mvx = lowpass3d_smooth_weighted(mvx,LowPassKernalSize,1,abs(u2));
		% 	mvy = lowpass3d_smooth_weighted(mvy,LowPassKernalSize,1,abs(v2));
		% 	mvz = lowpass3d_smooth_weighted(mvz,LowPassKernalSize,1,abs(w2));
	end

	if reverse_consistent == 1
		clear i2vxs u2 v2 w2 grad2;
	end
		
	d_mvx = mvx - old_mvx;
	d_mvy = mvy - old_mvy;
	d_mvz = mvz - old_mvz;
% 	
% 	if iter == 1
% 		old_d_mvx = d_mvx;
% 		old_d_mvy = d_mvy;
% 		old_d_mvz = d_mvz;
% 	else
% 		idx = find(old_d_mvx.*d_mvx < 0 & old_d_mvy.*d_mvy < 0 & old_d_mvz.*d_mvz < 0);
% 		factors(idx) = factors(idx)*0.6;
% 
% 		old_d_mvx = d_mvx;
% 		old_d_mvy = d_mvy;
% 		old_d_mvz = d_mvz;
% 	end


	if maxiter > 1
		fprintf('Compute i1vx ...\n');
		if ~isequal(offsets,[0 0 0])
			[mvy2,mvx2,mvz2] = expand_motion_field(mvy,mvx,mvz,dim1,offsets);
			i1vx1 = move3dimage(im1,mvy2,mvx2,mvz2);
			i1vx = i1vx1(yoffs,xoffs,zoffs);
		else
			if reverse_consistent == 1
				i1vx1 = move3dimage(im1,mvy/2,mvx/2,mvz/2);	
				i1vx = i1vx1;
				fprintf('Compute i2vx ...\n');
				i2vx1 = move3dimage(im2,-mvy/2,-mvx/2,-mvz/2);
				i2vx = i2vx1;
			else
				i1vx1 = move3dimage(im1,mvy,mvx,mvz);
				i1vx = i1vx1;
			end
		end

		% Update display
% 		if ~isempty(mainfigure)
% 			handles = guidata(mainfigure);
% 			%if get(handles.gui_handles.motioncheckbox,'Value') == 1
% 			% 		if GetMotionDisplaySelection(handles) > 1
% 			handles = guidata(mainfigure);
% 			handles.images(1).image_deformed = i1vx1;
% 			if reverse_consistent == 1
% 				handles.images(2).image_deformed = i2vx1;
% 			end
% 			handles.reg.mvx_iteration = -d_mvx;
% 			handles.reg.mvy_iteration = -d_mvy;
% 			handles.reg.mvz_iteration = -d_mvz;
% 			handles.reg.mvx_pass = mvx;
% 			handles.reg.mvy_pass = mvy;
% 			handles.reg.mvz_pass = mvz;
% 
% 			guidata(mainfigure,handles);
% 			% 			ConditionalRefreshDisplay(handles,1:9);
% 			ConditionalRefreshDisplay(handles,[4 5 7 9 10 12 14:18 20]);
% 			% 		end
% 			clear handles;
% 		end
	end

	%figure(1);imagesc(i1vx-i2vx);axis image;

	mv_diff = sqrt((d_mvx).^2 + (d_mvz).^2 + (d_mvz).^2);

	mrs=max(mv_diff(:));
	pause(0.01);

	% Convergence speed testing with ground truth, for testing purpose
	% Input mvx0,mvy0,mvz0 are the ground truth motion field
	if exist('mvx0','var') && ~isempty(mvx0)
		if reverse_consistent == 0
			error_sr = sqrt((mvx0-mvx).^2+(mvy0-mvy).^2+(mvz0-mvz).^2);
			max_errors(iter) = max(error_sr(:));
			mean_errors(iter) = mean(error_sr(:));
		else
			mvyt = mvy/2;
			mvxt = mvx/2;
			mvzt = mvz/2;
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
				error_sr = error_sr.*mask0;
			end

			max_errors(iter) = max(error_sr(:));
			mean_errors(iter) = mean(error_sr(:));
		end
		max_dvs(iter) = max(mv_diff(:));
		mean_dvs(iter) = mean(mv_diff(:));
		clear error_sr;
	end

	disp(sprintf('motion mean = %d, max = %d', mean(mv_diff(:)), mrs));
	clear mv_diff;

	if mrs < stop || max(factors(:)) < 1e-2
		break;
	end


	drawnow;

	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		break;	% break out off the loop
	end
end


% Convergence speed testing with ground truth, for testing purpose
if exist('mvx0','var') && ~isempty(mvx0)
	figure;plot(max_dvs);ylabel('Maximal motion at an iteration');
	figure;plot(mean_dvs);ylabel('Mean motion at an iteration');
	figure;plot(max_errors);ylabel('Maximal error from ground truth at an iteration');
	figure;plot(mean_errors);ylabel('Mean error from ground truth at an iteration');

	varargout{4} = max_dvs;
	varargout{5} = mean_dvs;
	varargout{6} = max_errors;
	varargout{7} = mean_errors;
end

varargout{1} = mvy;
varargout{2} = mvx;
varargout{3} = mvz;



