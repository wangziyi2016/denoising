function varargout = fast_free_form_method(method,mainfigure,im1,im2,voxelsizes,maxiter,stop,offsets,mvy0,mvx0,mvz0,mask0)
%{
% [mvy,mvx,mvz] = fast_free_form_method(method,mainfigure,im1,im2,voxelsizes=[1 1 1],maxiter=30,stop=2e-2,offsets=[0 0 0])
%
% Method = 1:	Original free form deformation method
% Method = 2:	symmetric free form deformation method

Reference: W. Lu, M. L. Chen et al. “Fast free-form deformable registration via calculus of variations,” Phys. Med. Biol. 49, 3067-87 (2004)


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

% Check the input parameters
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

Vy = zeros(dim2,'single'); Vx = Vy; Vz = Vy;

i1vx = im1(yoffs,xoffs,zoffs);
i2vx = im2;

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end


maxintensity = max(max(im1(:)),max(im2(:)));

% Iterations
for iter = 1:maxiter
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle sprintf(' Free form deformation - iter %d (%d)',iter,maxiter)]);
		drawnow;
	end
	
	% Gradient of the moving image
	[Iy,Ix,Iz] = gradient_3d_by_mask(i1vx);
	if method == 2
		[Iy2,Ix2,Iz2] = gradient_3d_by_mask(i2vx);
		Iy = (Iy+Iy2); clear Iy2;
		Ix = (Ix+Ix2); clear Ix2;
		Iz = (Iz+Iz2); clear Iz2;
	end
	
	Iy = Iy * voxelsizes(1);
	Ix = Ix * voxelsizes(2);
	Iz = Iz * voxelsizes(3);
	grad = sqrt(Iy.*Iy+Ix.*Ix+Iz.*Iz);

	diff = i2vx - i1vx;
	
	lambda = 0.2*maxintensity;
	
	[Vya,Vxa,Vza]=hs_velocity_avg3d(Vy,Vx,Vz);
	
	sumb = lambda*lambda+grad;
	
	dVy = (lambda*lambda*(Vya-Vy)-diff.*Iy)./sumb;
	dVx = (lambda*lambda*(Vxa-Vx)-diff.*Ix)./sumb;
	dVz = (lambda*lambda*(Vza-Vz)-diff.*Iz)./sumb;

	dV = sqrt(dVy.^2+dVx.^2+dVz.^2);
	maxv = max(dV(:));
	
	Vy = Vy + dVy;
	Vx = Vx + dVx;
	Vz = Vz + dVz;
	
	if method == 2
		i1vx = move3dimage(im1, Vy/2, Vx/2, Vz/2);
		i2vx = move3dimage(im2,-Vy/2,-Vx/2,-Vz/2);
	else
		i1vx = move3dimage(im1,Vy,Vx,Vz,'linear',offsets);
	end
	
	clear Iy Ix Iz sumb grad;
	
	%figure(1);imagesc(i1vx-i2vx);axis image;
	
	% Update display
% 	if ~isempty(mainfigure)
% 		handles = guidata(mainfigure);
% 		handles.images(1).image_deformed = i1vx;
% 		if method == 2
% 			handles.images(2).image_deformed = i2vx;
% 		end
% 		if GetMotionDisplaySelection(handles) > 1
% 			handles = guidata(mainfigure);
% 			handles.reg.mvx_iteration = -dVx;
% 			handles.reg.mvy_iteration = -dVy;
% 			handles.reg.mvz_iteration = -dVz;
% 			handles.reg.mvx_pass = Vx;
% 			handles.reg.mvy_pass = Vy;
% 			handles.reg.mvz_pass = Vz;
% 			guidata(mainfigure,handles);
% 			ConditionalRefreshDisplay(handles,1:9);
% 		else
% 			guidata(mainfigure,handles);
% 			ConditionalRefreshDisplay(handles,[4:5 7 9]);
% 		end
% 		clear handles;
% 	end

	% Convergence speed testing with ground truth, for testing purpose
	% Input mvx0,mvy0,mvz0 are the ground truth motion field
	if exist('mvx0','var') && ~isempty(mvx0) 
		if method == 1
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
				error_sr = error_sr.*mask0;
			end
			
			max_errors(iter) = max(error_sr(:));
			mean_errors(iter) = mean(error_sr(:));
		end
		max_dvs(iter) = maxv;
		mean_dvs(iter) = mean(dV(:));
		clear error_sr;
	end

	fprintf('iter %d (%d): motion mean = %d, max = %d\n', iter, maxiter, mean(dV(:)), maxv);
	clear dVy dVx dVz dV;

	if maxv < stop
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

varargout{1} = Vy;
varargout{2} = Vx;
varargout{3} = Vz;



