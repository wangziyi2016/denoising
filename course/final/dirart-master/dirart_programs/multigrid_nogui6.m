function [mvy,mvx,mvz,i1vx,maxm,meanm,maxe,meane]=multigrid_nogui6(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,offsets,smoothing_settings,modulation,filter_type,img2mask,mvy0,mvx0,mvz0,mvygt,mvxgt,mvzgt)
%
% Usage:
% 1: [mvy,mvx,mvz,i1vx]=multigrid_nogui6(method,img1,img2,voxelsizes,stagess)
% 2: [mvy,mvx,mvz,i1vx]=multigrid_nogui6(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,offsets,smoothing_settings,modulation)
% 3: [mvy,mvx,mvz,i1vx]=multigrid_nogui6(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,offsets,smoothing_settings,modulation,img2mask,mvy0,mvx0,mvz0)
% 4: [mvy,mvx,mvz,i1vx,maxm,meanm,maxe,meane]=multigrid_nogui6(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,offsets,smoothing_settings,modulation,img2mask,mvy0,mvx0,mvz0,mvygt,mvxgt,mvzgt)
%
% The multi-grid framework, supports images upto 4 coarse levels
%
% Changes:
%
% Version 4
% In coarse level, if the motion vector magnitude is less than 0.4, then
% set it to 0 because we could safely recover it in the finer level
%
% Version 5 : Try to fix the errors near the boundaries in the earlier stagess
% - Limit the motion vector amplitude (<1) for each stages
% - Limit the motion vector amplitude (<1) for each pass within the stages
% - Apply multiple passes for each earlier stages so that the motion field is
%   increasing gratually and under control
% - Save delta motion field for each pass and for each stages
% - Save images in PNG (after maximizing the figure window)
%
% Version 6: Be able to run with or without GUI
%
% If calling from GUI, all input parameters could be left empty
% If calling from command line, then the first 3 parameters needs to be
% given.
%
% Changes:	Disable all GUIs
%
% Changes in v2:
% - Allow img1 to be larger than img2
% - add parameter zoffset
%
% Changes in v3:
% - To support mask for img2 and to reset all motion fields to 0 outside
% the mask
%
% Changes 10/21/2006
% - If img1 is larger than img2, the larger img1 will be passed into each
% optical flow routine, so that image gradient could be computed more
% accurately in the optical flow routine.
% - Accept initial value for mvz
%
% Changes in v4
% Using a different way to apply initial motion field mvx0,mvy0,mvz0. Will
% deform img1 first by using these initial motion field, then apply regular
% method on the deform the img1. The final motion field will be the resultant
% motion field computed by using the deformed img1 + the initial motion
% field
% 
% Changes in v5
% Fix the motion field / i1vx recalculation bug
%
% Version 6: 
% 1. support full offsets, not only zoffsets
% 2. support arbitrary image dimension 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

setpath;
maxmotion = 2;
displayflag = 0;

% Check input parameters

if( ~exist('voxelsizes','var') || isempty(voxelsizes) )
	voxelsizes = [1 1 1];
end
voxelsizes = voxelsizes / min(voxelsizes);

if ~exist('offsets','var') || isempty(offsets) 
	offsets = [0 0 0];
elseif length(offsets) == 1
	offsets = [0 0 offsets];
end

% These two vector control the number of passes and iterations
if ~exist('maxiters','var') || isempty(maxiters)
	maxiters = [1 2 3 4 5]*20;
end

if ~exist('passesinstages','var') || isempty(passesinstages)
	passesinstages = [2 3 4 5 6];
end

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

if ~exist('smoothing_settings','var') || isempty(smoothing_settings)
	smoothing_settings = [3 0];
end

if ~exist('modulation','var') || isempty(modulation)
	modulation = 0;
end

if ~exist('filter_type','var') || isempty(filter_type)
	filter_type = 1;
end

if( ~exist('img2mask','var') || isempty(img2mask) )
	img2mask = ones(size(img2),'single');
end
img2mask = single(img2mask);

% Options
% check_motion_vector_magnitude = 1;
check_motion_vector_magnitude = 0;

ct0 = cputime;

% If initial motion field is passed in, then deform the image 1 before
% using it
if ( exist('mvz0','var') && ~isempty(mvz0) && exist('mvx0','var') && ~isempty(mvx0) && exist('mvy0','var') && ~isempty(mvy0) ) 
	[mvyL0,mvxL0,mvzL0]=expand_motion_field(mvy0,mvx0,mvz0,size(img1),offsets);
    img1_org = img1;
	disp('Deforming img1 ...');
	img1 = move3dimage(img1,mvyL0,mvxL0,mvzL0,'linear',[],modulation);
% 	img1 = move3dimage(img1,mvyL0,mvxL0,mvzL0,'cubic',[],modulation);
	img1 = max(img1,0);
	
	clear mvy0 mvx0 mvz0;
end

[img1_2,img1_4,img1_8,img2_2,img2_4,img2_8,img2mask_2,img2mask_4,img2mask_8]=Multigrid_Downsample_All(filter_type,img1,img2,img2mask,stagess,displayflag);
if stagess > 4
	img1_16 = GPReduce(img1_8);
	img2_16 = GPReduce(img2_8);
	img2mask_16 = GPReduce(img2mask_8);
end

% For convergence testing only
if exist('mvxgt','var')
	mvxgt_1 = mvxgt;
	mvygt_1 = mvygt;
	mvzgt_1 = mvzgt;
	
	mvxgt_2 = GPReduce(mvxgt)/2;
	mvxgt_4 = GPReduce(mvxgt_2)/2;
	mvxgt_8 = GPReduce(mvxgt_4)/2;

	mvygt_2 = GPReduce(mvygt)/2;
	mvygt_4 = GPReduce(mvygt_2)/2;
	mvygt_8 = GPReduce(mvygt_4)/2;

	mvzgt_2 = GPReduce(mvzgt)/2;
	mvzgt_4 = GPReduce(mvzgt_2)/2;
	mvzgt_8 = GPReduce(mvzgt_4)/2;
	
	if stagess> 4
		mvxgt_16 = GPReduce(mvxgt_8)/2;
		mvygt_16 = GPReduce(mvygt_8)/2;
		mvzgt_16 = GPReduce(mvzgt_8)/2;
	end
		
	meane = [];
	meanm = [];
	maxe = [];
	maxm = [];
end

disp(sprintf('It took %.2f seconds to downsample the images',cputime-ct0));

calsecs = 0;	% Time on actual computation
ct0=cputime;


% Starting the stagess
for stages = 1:stagess
	disp(sprintf('\n\nStarting stages %d\n',stages));
	real_stages = stagess-stages+1;
	ct1 = cputime;
	
	% setting images
	switch real_stages
		case 5
			im1 = img1_16;
			im2 = img2_16;
			im2mask = img2mask_16;
		case 4
			im1 = img1_8;
			im2 = img2_8;
			im2mask = img2mask_8;
		case 3
			im1 = img1_4;
			im2 = img2_4;
			im2mask = img2mask_4;
		case 2
			im1 = img1_2;
			im2 = img2_2;
			im2mask = img2mask_2;
		case 1
			im1 = img1;
			im2 = img2;
			im2mask = img2mask;
	end
	
	im1 = single(im1);
	im2 = single(im2);
	im2mask = single(im2mask>0);

	% Normalize images
	maxv = max(max(im1(:)),max(im2(:)));
	im1 = im1/maxv;
	im2 = im2/maxv;
	dim1 = mysize(im1);
	dim2 = mysize(im2);

	image_current_offsets = floor(offsets / (2^(real_stages-1)));
	
	% Initialze motion fields for this stages
	ctc = cputime;
	if( stages == 1 )
		disp(sprintf('Initialize motion fields'));
		mvy = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		mvx = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		mvz = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		i1vx = im1;
	else
		disp(sprintf('stages %d - Upscaling the motion field ...', stages));
		[mvy,mvx,mvz] = recalculate_mvs(mvy,mvx,mvz,displayflag);
		if ~isequal(size(mvy),dim2)
			mvy = mvy(1:dim2(1),1:dim2(2),1:dim2(3));
			mvx = mvx(1:dim2(1),1:dim2(2),1:dim2(3));
			mvz = mvz(1:dim2(1),1:dim2(2),1:dim2(3));
		end
		
		disp('Upscaling motion field is finished.');
	end
	
	if stages > 1
		disp('Computing moved image by interpolating ...');
		if ~isequal(dim1,dim2)
			[mvyL_stages,mvxL_stages,mvzL_stages]=expand_motion_field(mvy,mvx,mvz,size(im1),image_current_offsets);
			i1vx = move3dimage(im1,mvyL_stages,mvxL_stages,mvzL_stages,'linear',[],modulation);
% 			i1vx = move3dimage(im1,mvyL_stages,mvxL_stages,mvzL_stages,'cubic',[],modulation);
		else
			i1vx = move3dimage(im1,mvy,mvx,mvz,'linear',image_current_offsets,modulation);
% 			i1vx = move3dimage(im1,mvy,mvx,mvz,'cubic',image_current_offsets,modulation);
		end
		i1vx = max(i1vx,0);

		disp('Computing moved image is finished');		
	end
	calsecs = calsecs + (cputime-ctc);

	disp(sprintf('stages %d - Saving initial variables ...', stages));

	% Initial motion field for the current stages
% 	mvx_this_stages = zeros(size(mvx));
% 	mvy_this_stages = mvx_this_stages;
% 	mvz_this_stages = mvx_this_stages;

	Numpasses = passesinstages(real_stages);

	if exist('mvxgt','var')
		% Convergence checking
		gtx = eval(['mvxgt_' num2str(2^(real_stages-1))]);
		gty = eval(['mvygt_' num2str(2^(real_stages-1))]);
		gtz = eval(['mvzgt_' num2str(2^(real_stages-1))]);
	end

	% Starting passes within a stages
	for pass = 1:Numpasses
		ct2 = cputime;
		fprintf('Computing motion: stages %d - pass %d\n', stages, pass);
		
		ctc = cputime;
		if method ~= 9 && method ~= 12
			[mvy1,mvx1,mvz1] = reg_method_dispatch(method,[],i1vx,im2,[],voxelsizes,maxiters(real_stages),stop,[],[],[],image_current_offsets);
		else
			if pass == 1
				[mvy1,mvx1,mvz1] = reg_method_dispatch(method,[],i1vx,im2,[],voxelsizes,maxiters(real_stages),stop,mvy,mvx,mvz,image_current_offsets);
			else
				[mvy1,mvx1,mvz1] = reg_method_dispatch(method,[],i1vx,im2,[],voxelsizes,maxiters(real_stages),stop,mvy + mvy_this_stages,mvx + mvx_this_stages,mvz + mvz_this_stages,image_current_offsets);
			end
		end
		
% 		fprintf('Low-pass smoothing the motion fields...\n');
% 		mvy1 = lowpass3d(mvy1,stages);
% 		mvx1 = lowpass3d(mvx1,stages);
% 		mvz1 = lowpass3d(mvz1,stages);

		fprintf('Motion computation stages %d,%d is finished\n',stages,pass);
		
		if check_motion_vector_magnitude == 1
			if stages < stagess
				[mvx1,mvy1,mvz1]=CheckMagnitude1(mvx1,mvy1,mvz1,maxmotion/passesinstages(real_stages));
			end
			
% 			if stages < stagess
% 				[mvx1,mvy1,mvz1]=CheckMagnitude2(mvx1,mvy1,mvz1);
% 			end
		end
		
		mvy1 = mvy1.*im2mask;
		mvx1 = mvx1.*im2mask;
		mvz1 = mvz1.*im2mask;

		if pass == 1
			mvy_this_stages = mvy1;
			mvx_this_stages = mvx1;
			mvz_this_stages = mvz1;
		else
			disp('Computing result motion field for this pass by interpolating ...');
			if isequal(dim1,dim2)
				mvy_this_stages = move3dimage(mvy_this_stages,mvy1,mvx1,mvz1,'linear') + mvy1;
				mvx_this_stages = move3dimage(mvx_this_stages,mvy1,mvx1,mvz1,'linear') + mvx1;
				mvz_this_stages = move3dimage(mvz_this_stages,mvy1,mvx1,mvz1,'linear') + mvz1;
			else
				mvy_this_stages = move3dimage(mvyL,mvy1,mvx1,mvz1,'linear',image_current_offsets) + mvy1;
				mvx_this_stages = move3dimage(mvxL,mvy1,mvx1,mvz1,'linear',image_current_offsets) + mvx1;
				mvz_this_stages = move3dimage(mvzL,mvy1,mvx1,mvz1,'linear',image_current_offsets) + mvz1;
			end
		end
		
		if smoothing_settings(2) > 0
			fprintf('Smoothing the motion field, kernel size = %d: mvy',smoothing_settings(2));
			mvy_this_stages = lowpass3d(mvy_this_stages,smoothing_settings(2));
			fprintf(',mvx');
			mvx_this_stages = lowpass3d(mvx_this_stages,smoothing_settings(2));
			fprintf(',mvz');
			mvz_this_stages = lowpass3d(mvz_this_stages,smoothing_settings(2));
			fprintf('\n');
		end
		
		
		if exist('mvxgt','var')
			disp('Computing result motion field for this stages by interpolating ...');
			tmvy = move3dimage(mvy,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvy_this_stages;
			tmvx = move3dimage(mvx,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvx_this_stages;
			tmvz = move3dimage(mvz,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvz_this_stages;

			% Convergence checking
			erx = tmvx-gtx;
			ery = tmvy-gty;
			erz = tmvz-gtz;

			ers = sqrt(erx.^2+ery.^2+erz.^2);
			meane(end+1) = mean(ers(:));
			maxe(end+1) = max(ers(:));
			clear erx ery erz ers tmvy tmvx tmvz;
			
			mvs = sqrt(mvy1.^2+mvx1.^2+mvz1.^2);
			meanm(end+1) = mean(mvs(:));
			maxm(end+1) = max(mvs(:));
			clear mvs;
		end
		
		disp('Computing moved image by interpolating ...');
		if ~isequal(dim1,dim2)
			[mvyL,mvxL,mvzL]=expand_motion_field(mvy_this_stages,mvx_this_stages,mvz_this_stages,size(im1),image_current_offsets);
			if stages == 1
				i1vx = move3dimage(im1,mvyL,mvxL,mvzL,'linear',[],modulation);
% 				i1vx = move3dimage(im1,mvyL,mvxL,mvzL,'cubic',[],modulation);
			else
				i1vx = move3dimage(im1,mvyL+mvyL_stages,mvxL+mvxL_stages,mvzL+mvzL_stages,'linear',[],modulation);
% 				i1vx = move3dimage(im1,mvyL+mvyL_stages,mvxL+mvxL_stages,mvzL+mvzL_stages,'cubic',[],modulation);
			end
		else
			i1vx = move3dimage(im1,mvy+mvy_this_stages,mvx+mvx_this_stages,mvz+mvz_this_stages,'linear',image_current_offsets,modulation);
% 			i1vx = move3dimage(im1,mvy+mvy_this_stages,mvx+mvx_this_stages,mvz+mvz_this_stages,'cubic',image_current_offsets,modulation);
		end
		i1vx = max(i1vx,0);

		disp('Computing moved image is finished');
		calsecs = calsecs + (cputime-ctc);

		clear mvx1 mvy1 mvz1;
		
		% Compute the image statistics
		if ~isequal(dim1,dim2)
			i1vx2 = i1vx((1:dim2(1))+image_current_offsets(1),(1:dim2(2))+image_current_offsets(2),(1:dim2(3))+image_current_offsets(3));
		else
			i1vx2 = i1vx;
		end

		[MI,NMI,MI3,CC,CC2,COV,MSE] = images_info(i1vx2,im2,'MI','NMI','MI3','CC','CC2','cOV','MSE');
		fprintf('stages %d,%d, MI = %d\n',stages, pass, MI);
		fprintf('stages %d,%d, NMI = %d\n',stages, pass, NMI);
		fprintf('stages %d,%d, MI3 = %d\n',stages, pass, MI3);
		fprintf('stages %d,%d, CC = %d\n',stages, pass, CC);
		fprintf('stages %d,%d, CC2 = %d\n',stages, pass, CC2);
		fprintf('stages %d,%d, COV = %d\n',stages, pass, COV);
		fprintf('stages %d,%d, MSE = %d\n',stages, pass, MSE);
		clear i1vx2;

		disp(sprintf('stages %d,%d - Finished', stages,pass));

		disp(sprintf('This pass used %.2f seconds to finish.\n',cputime-ct2));
		if method == 9	|| method > 16 % levelset motion or demon methods
			break;	% Don't pass here
		end
	end
	
	if check_motion_vector_magnitude == 1
		if stages < 5
			[mvx_this_stages,mvy_this_stages,mvz_this_stages]=CheckMagnitude1(mvx_this_stages,mvy_this_stages,mvz_this_stages,maxmotion);
		end
		
 		if stages < 4
 			[mvx_this_stages,mvy_this_stages,mvz_this_stages]=CheckMagnitude2(mvx_this_stages,mvy_this_stages,mvz_this_stages);
 		end
	end
	
	if stages == 1
		mvy = mvy_this_stages;
		mvx = mvx_this_stages;
		mvz = mvz_this_stages;
	else
		disp('Computing result motion field for this stages by interpolating ...');
		if ~isequal(dim1,dim2)
			mvy = move3dimage(mvyL_stages,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear',image_current_offsets) + mvy_this_stages;
			mvx = move3dimage(mvxL_stages,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear',image_current_offsets) + mvx_this_stages;
			mvz = move3dimage(mvzL_stages,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear',image_current_offsets) + mvz_this_stages;
		else
			mvy = move3dimage(mvy,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvy_this_stages;
			mvx = move3dimage(mvx,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvx_this_stages;
			mvz = move3dimage(mvz,mvy_this_stages,mvx_this_stages,mvz_this_stages,'linear') + mvz_this_stages;
		end
	end
	
	if smoothing_settings(2) > 0
		fprintf('Smoothing the motion field, kernel size = %d: mvy',smoothing_settings(2));
		mvy = lowpass3d(mvy,smoothing_settings(2));
		fprintf(',mvx');
		mvx = lowpass3d(mvx,smoothing_settings(2));
		fprintf(',mvz');
		mvz = lowpass3d(mvz,smoothing_settings(2));
		fprintf('\n');
	end

	
	if exist('mvxgt','var')
		% Convergence checking
		erx = mvx-gtx;
		ery = mvy-gty;
		erz = mvz-gtz;
		
		ers = sqrt(erx.^2+ery.^2+erz.^2);
		meane(end+1) = mean(ers(:));
		maxe(end+1) = max(ers(:));
		
		clear gtx gty gtz erx ery erz ers;
		
		mvs = sqrt(mvx_this_stages.^2+mvy_this_stages.^2+mvz_this_stages.^2);
		meanm(end+1) = mean(mvs(:));
		maxm(end+1) = max(mvs(:));
		clear mvs
	end
		
    mvx = mvx.*im2mask;
    mvy = mvy.*im2mask;
    myz = mvz.*im2mask;
	
	clear mvx_this_stages mvy_this_stages mvz_this_stages;
	
	disp(sprintf('stages %d - Finished', stages));
	disp(sprintf('\nstages %d is finished, used %.2f seconds.\n\n',stages,cputime-ct1));
end

% if ~isequal(dim1,dim2)
% 	i1vx = i1vx((1:dim2(1))+image_current_offsets(1),(1:dim2(2))+image_current_offsets(2),(1:dim2(3))+image_current_offsets(3));
% end

if exist('mvxgt','var')
	% Convergence reports
	figure;plot(meane,'+');ylabel('Mean error');
	figure;plot(maxe,'+');ylabel('Max error');
	figure;plot(meanm,'+');ylabel('Mean motion');
	figure;plot(maxm,'+');ylabel('Max motion');
end


if ( exist('mvyL0','var') )
	disp('Computing final motion field by interpolating ...');
	mvy1 = move3dimage(mvyL0,mvy,mvx,mvz,'linear',image_current_offsets);
	mvx1 = move3dimage(mvxL0,mvy,mvx,mvz,'linear',image_current_offsets);
	mvz1 = move3dimage(mvzL0,mvy,mvx,mvz,'linear',image_current_offsets);
	mvy = mvy + mvy1;
    mvx = mvx + mvx1;
    mvz = mvz + mvz1;
	clear mvy1 mvx1 mvz1;
end


disp('All finished');
disp(sprintf('It took %.2f seconds to finish the entire multigrid registration',cputime-ct0));
disp(sprintf('It took %.2f seconds with actually computation',calsecs));
return;



function [mvx,mvy,mvz]=CheckMagnitude1(mvx,mvy,mvz,thres)
% This stages will restrict the magnitude of the motion field
% in the earlier stagess to be less than 1. Such a
% restriction will help to solve the outlier and errors
% near the boundaries
mv = sqrt(mvx.^2+mvy.^2+mvz.^2);
mv2 = min(mv,thres);
factor = mv2 ./ (mv + (mv == 0 ));
mvx = mvx .* factor;
mvy = mvy .* factor;
mvz = mvz .* factor;
% mvx = lowpass3d(mvx,1);
% mvy = lowpass3d(mvy,1);
% mvz = lowpass3d(mvz,1);
clear mv mv2 factor;
return;

function [mvx,mvy,mvz]=CheckMagnitude2(mvx,mvy,mvz)
% This stages will reduce the magnitude of the motion field
% in the earlier stagess if the motion could be recovered in
% later multigrid stagess
mv = sqrt(mvx.^2+mvy.^2+mvz.^2);
mv2 = (mv - 0.4) .* (mv > 0.4);
factor = mv2 ./ (mv + (mv == 0 ));
mvx = mvx .* factor;
mvy = mvy .* factor;
mvz = mvz .* factor;
% mvx = lowpass3d(mvx,1);
% mvy = lowpass3d(mvy,1);
% mvz = lowpass3d(mvz,1);
clear mv mv2 factor;
return;

