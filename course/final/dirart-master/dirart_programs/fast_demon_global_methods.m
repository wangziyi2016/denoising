function [mvy,mvx,mvz,i1vx] = fast_demon_global_methods(method,mainfigure,im1,im2,voxelsizes,maxiter,stop,LowPassKernalSize,offsets)
%{
% [mvy,mvx,mvz] = fast_demon_global_methods(method,mainfigure,im1,im2,voxelsizes,maxiter=20,stop=1e-2,LowPassKernalSize=2,offsets=[0 0 0])
%
% In the fast demon method, the term "I1(X+V)" is replaced by
% "I1(X)+del(I1)*V" in order to avoid the per iteration computation of
% I1(X+V). Such an approximation is good if V is smaller (<2)
%
% Method =	1:	Original demon method



Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}


% Check the input parameters
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

% Initialization
dim2 = mysize(im2);
dim1 = mysize(im1);
yoffs = (1:dim2(1))+offsets(1);
xoffs = (1:dim2(2))+offsets(2);
zoffs = (1:dim2(3))+offsets(3);

mvx = zeros(dim2,'single'); mvy = mvx; mvz = mvx;
i1vx1 = im1;
i1vx = 	i1vx1(yoffs,xoffs,zoffs);

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

factors = ones(size(im2),'single');

% Gradient of the target image
im2s = lowpass3d(im2,1);
[v2,u2,w2] = gradient_3d_by_mask(im2s);
v2 = v2 * voxelsizes(1);
u2 = u2 * voxelsizes(2);
w2 = w2 * voxelsizes(3);
grad2 = sqrt(v2.*v2+u2.*u2+w2.*w2);

im1s = lowpass3d(im1,1);
[v1,u1,w1] = gradient_3d_by_mask(im1s);
v1 = v1(yoffs,xoffs,zoffs)*voxelsizes(1);
u1 = u1(yoffs,xoffs,zoffs)*voxelsizes(2);
w1 = w1(yoffs,xoffs,zoffs)*voxelsizes(3);
grad1 = sqrt(v1.*v1+u1.*u1+w1.*w1);

It = im2 - im1(yoffs,xoffs,zoffs);

% Iterations
for iter = 1:maxiter
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle sprintf(' - iteration %d',iter)]);
		drawnow;
	end

	diff = It + (mvx.*u1 + mvy.*v1 + mvz.*w1);
	
	switch method
		case 1	% Original demon method
			temp1 = grad2.*grad2 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1<1e-4));
			d_mvy = temp1 .* v2;
			d_mvx = temp1 .* u2;
			d_mvz = temp1 .* w2;
		case 2	% Original demon method
			temp1 = grad1.*grad1 + diff.*diff;
			temp1 = diff ./ (temp1 + (temp1<1e-4));
			d_mvy = temp1 .* v1;
			d_mvx = temp1 .* u1;
			d_mvz = temp1 .* w1;
		case 3 % Demon + elastic regularization constraint
			beta = 1;
			temp1 = grad1.*grad1 + diff.*diff;
			alpha = 1 ./ (temp1 + (temp1<1e-4));
			[laplax,laplay,laplaz] = vector_laplacian(mvx,mvy,mvz);
			d_mvy = (diff .* v1 ).*alpha - beta*laplay;
			d_mvx = (diff .* u1 ).*alpha - beta*laplax;
			d_mvz = (diff .* w1 ).*alpha - beta*laplaz;
	end

	clear i1vxs u v w grad diff;
	
	old_mvx = mvx;
	old_mvy = mvy;
	old_mvz = mvz;

	mvx = mvx - d_mvx.*factors;
	mvy = mvy - d_mvy.*factors;
	mvz = mvz - d_mvz.*factors;
	
	if LowPassKernalSize > 0
		mvx = lowpass3d(mvx,LowPassKernalSize);
		mvy = lowpass3d(mvy,LowPassKernalSize);
		mvz = lowpass3d(mvz,LowPassKernalSize);
	end

	d_mvx = mvx - old_mvx;
	d_mvy = mvy - old_mvy;
	d_mvz = mvz - old_mvz;
	
	if iter == 1
		old_d_mvx = d_mvx;
		old_d_mvy = d_mvy;
		old_d_mvz = d_mvz;
	else
		idx = find(old_d_mvx.*d_mvx < 0 & old_d_mvy.*d_mvy < 0 & old_d_mvz.*d_mvz < 0);
		factors(idx) = factors(idx)*0.6;

		old_d_mvx = d_mvx;
		old_d_mvy = d_mvy;
		old_d_mvz = d_mvz;
	end

	% Update display
	if ~isempty(mainfigure)
		handles = guidata(mainfigure);
		if GetMotionDisplaySelection(handles) > 1
			handles = guidata(mainfigure);
			if isequal(dim1,dim2)
				handles.images(1).image_deformed = im1 + (mvx.*u1 + mvy.*v1 + mvz.*w1);
			end
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

	mv_diff = sqrt((d_mvx).^2 + (d_mvz).^2 + (d_mvz).^2);

	mrs=max(mv_diff(:));
	pause(0.01);

	if mrs < stop || max(factors(:)) < 1e-2
		break;
	end

	disp(sprintf('iter %d: max motion = %d', iter, mrs));
	clear mv_diff;

	drawnow;

	abortflag = CheckAbortPauseButtons(mainfigure,0);
	if abortflag > 0
		return;	% break out off the loop
	end
end



