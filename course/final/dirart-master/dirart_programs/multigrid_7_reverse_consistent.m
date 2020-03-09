function [mvy,mvx,mvz,i1vx,i2vx]=multigrid_7_reverse_consistent(method,img1,img2,voxelsize_ratio,stages,startingstage,mainfigure,save_results,resultdir,prefix,smoothing_settings,filter_type)
%
% The inverse consistency multi-grid framework, runs from the GUI
% Usage:
%	[mvy,mvx,mvz,i1vx,i2vx]=
%       multigrid_7_reverse_consistent(method,img1,img2,voxelsize_ratio,
%                stages,startingstage,mainfigure,save_results,resultdir,prefix,smoothing_settings,filter_type)
%
%   Image #1 and #2 must be in the same dimension
% 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

setpath;

maxmotion = 0.4;

if( ~exist('startingstage','var') || isempty(startingstage) )
	startingstage = 1;
end

if( ~exist('mainfigure','var') )
	mainfigure = [];
end

if( ~exist('prefix','var') || isempty(prefix) )
	prefix = '';
else
	prefix = [prefix '_'];
end

% Options
check_motion_vector_magnitude = 1;
% check_motion_vector_magnitude = 0;

compute_reverse_motion_by_integration = 0;
% compute_reverse_motion_by_integration = 1;


% User select image filenames

if( ~exist('voxelsize_ratio','var') || isempty(voxelsize_ratio) )
	voxelsize_ratio = InputImageVoxelSizeRatio();
end
voxelsize_ratio = voxelsize_ratio / min(voxelsize_ratio);

if ~exist('smoothing_settings','var') || isempty(smoothing_settings)
	smoothing_settings = [3 0];
end
smoothing_settings = [smoothing_settings 0 0];

if ~exist('save_results','var')
	save_results = 0;
end

if save_results >= 1
	if ~exist('resultdir','var') || isempty(resultdir)
		resultdir = uigetdir('', 'Select a working folder to save intermediate files and results');
	end
	if resultdir(end) ~= filesep
		resultdir = [resultdir filesep];
	end

	if save_results >= 2
		curdir = pwd;
		cd(resultdir);
		nowstr = datestr(now,'dd-mm-yy HH-MM-SS');
		logname = [resultdir nowstr '.log'];
		[FileName,PathName] = uiputfile('*.log','Log file name',logname);
		if FileName ~= 0
			logname = [PathName FileName];
		end
		cd(curdir);
		diary(logname);
	end
else
	resultdir = '';
end

if ~isempty(mainfigure)
	set(mainfigure,'Name','Checking and creating image files ...');
else
	% Check the exist files and create down sampled images
	H = waitbar(0,'Checking and creating image files ...');
	set(H,'Name','Multigrid Inverse Consistency');
	set(H,'NumberTitle','off');
end

fprintf('\n\nMultigrid Inverse Consistency\n\n\n');


if stages > 1
	[img1_2,img1_4,img1_8,img2_2,img2_4,img2_8]=Multigrid_Downsample_All(filter_type,img1,img2,[],stages,~isempty(mainfigure));
end

if stages > 4
	img1_16 = GPReduce(img1_8);
	img2_16 = GPReduce(img2_8);
end


guisecs = 0;	% Time on GUI
calsecs = 0;	% Time on actual computation

ct0=cputime;
if( startingstage ~= 1 )
	if ~isempty(mainfigure)
		set(mainfigure,'Name',sprintf('Loading stage%d_mvs.mat',startingstage-1));
	else
		figure(H);waitbar(0,H,sprintf('Loading stage%d_mvs.mat',startingstage-1));
	end
	
	load(sprintf('%s%s_stage%d_mvs.mat',resultdir,prefix,startingstage-1));
end

if ~isempty(mainfigure)
	handles = guidata(mainfigure);
	handles = Clear_Results(handles);
	
	image_infos{1} = GenerateMultigridImageInfo(handles.images(1));
	image_infos{2} = GenerateMultigridImageInfo(handles.images(2));
	
	passes_in_stage = handles.reg.passes_in_stages;
	stop = handles.reg.minimal_max_motion_per_iteration;
	stop2 = handles.reg.minimal_max_motion_per_pass;
	maxiters = handles.reg.maxiters;
	
	guidata(mainfigure,handles);
else
	passes_in_stage = [1 2 3 3 3]*2;
	stop = 2e-3;
	stop2 = 1e-1;
	maxiters = [1 2 3 4 5]*20;
end


abortflag = 0;
lastStage = 1;
for stage = startingstage:stages
	real_stage = stages + 1 - stage;
	ct1 = cputime;
	fprintf('\n\nStarting stage %d\n\n',stage);
	
	% setting images
	switch real_stage
		case 5
			im1 = img1_16;
			im2 = img2_16;
		case 4
			im1 = img1_8;
			im2 = img2_8;
		case 3
			im1 = img1_4;
			im2 = img2_4;
		case 2
			im1 = img1_2;
			im2 = img2_2;
		case 1
			im1 = img1;
			im2 = img2;
	end
	im1 = single(im1);
	im2 = single(im2);

	dim1 = mysize(im1);
	dim2 = mysize(im2);
	
	% Perform intensity remapping to boost low intensity
	
	% Initialze motion fields
	ctc = cputime;
	if( stage == 1 )
		fprintf('Initialize motion fields\n');
		mvy = zeros(dim2,'single');
		mvx = zeros(dim2,'single');
		mvz = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		imvx = mvx;
		imvy = mvy;
		imvz = mvz;
		i1vx = im1;
		i2vx = im2;
		
		if compute_reverse_motion_by_integration == 1
			% forward motion fields
			mvyf = mvy; mvxf = mvx; mvzf = mvz;
			imvyf = mvy; imvxf = mvy; imvzf = mvy;
		end
	else
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Upscaling the motion field ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Upscaling the motion field ...', stage));
		end
		fprintf('stage %d - Upscaling the motion field ...\n', stage);
		%load(sprintf('%s%s_stage%d_mvs.mat',resultdir,prefix,stage-1));
		disp('Upscaling motion field by interpolating ...');
		[mvy,mvx,mvz] = recalculate_mvs(mvy,mvx,mvz,0);
		if ~isequal(size(mvy),dim2)
			mvy = mvy(1:dim2(1),1:dim2(2),1:dim2(3));
			mvx = mvx(1:dim2(1),1:dim2(2),1:dim2(3));
			mvz = mvz(1:dim2(1),1:dim2(2),1:dim2(3));
		end

		disp('Upscaling motion field is finished.');

		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Computing the moved image ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Computing the moved image ...', stage));
		end
		disp('Computing moved image by interpolating ...');
% 		i1vx = move3dimage(im1, mvy/2, mvx/2, mvz/2);
		i1vx = move3dimage(im1, mvy, mvx, mvz);

		[imvy,imvx,imvz] = recalculate_mvs(imvy,imvx,imvz,0);
		if ~isequal(size(imvy),dim2)
			imvy = imvy(1:dim2(1),1:dim2(2),1:dim2(3));
			imvx = imvx(1:dim2(1),1:dim2(2),1:dim2(3));
			imvz = imvz(1:dim2(1),1:dim2(2),1:dim2(3));
		end
% 		i2vx = move3dimage(im2,imvy/2,imvx/2,imvz/2);
		i2vx = move3dimage(im2,imvy,imvx,imvz);
		disp('Computing moved image is finished');		
		
		if compute_reverse_motion_by_integration == 1
			% double sampling the forward motion fields
			[mvyf,mvxf,mvzf] = recalculate_mvs(mvyf,mvxf,mvzf,0);
			[imvyf,imvxf,imvzf] = recalculate_mvs(imvyf,imvxf,imvzf,0);
			if ~isequal(size(mvy),dim2)
				mvyf = mvyf(1:dim2(1),1:dim2(2),1:dim2(3));
				mvxf = mvxf(1:dim2(1),1:dim2(2),1:dim2(3));
				mvzf = mvzf(1:dim2(1),1:dim2(2),1:dim2(3));
				imvyf = imvyf(1:dim2(1),1:dim2(2),1:dim2(3));
				imvxf = imvxf(1:dim2(1),1:dim2(2),1:dim2(3));
				imvzf = imvzf(1:dim2(1),1:dim2(2),1:dim2(3));
			end
		end

	end
	
	calsecs = calsecs + (cputime-ctc);
	
	ctg = cputime;
	if( ~isempty(mainfigure) )
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Updating GUI ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Updating GUI ...', stage));
		end
		handles = guidata(mainfigure);
		handles.images(1).image_deformed = i1vx;
		handles.images(2).image_deformed = i2vx;
		handles.images(1).image = im1;
		handles.images(2).image = im2;

		handles.images(1).voxelsize = image_infos{1}(real_stage).voxelsize;
		handles.images(1).origin = image_infos{1}(real_stage).origin;
		handles.images(2).voxelsize = image_infos{2}(real_stage).voxelsize;
		handles.images(2).origin = image_infos{2}(real_stage).origin;
		
		handles.reg.dvf.x = mvx;
		handles.reg.dvf.y = mvy;
		handles.reg.dvf.z = mvz;
		handles = FillDVFInfo(handles,3);

		handles = configure_sliders(handles,real_stage,lastStage);
		guidata(mainfigure,handles);

		RefreshDisplay(handles);

		%clear mvx  mvy  mvz;

		% Call motion estimation methods to compute motion fields
		if isempty(method)
			method = get(handles.gui_handles.regmethodpopupmenu,'Value');
		end
		clear handles;
	end
	
	if method == 9	% levelset motion
		passes_in_stage = [1 1 1 1 1];
	elseif abortflag == 1
		passes_in_stage = 0;
	end

	if mod(save_results,2) == 1
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Saving initial variables ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Saving initial variables ...', stage));
		end
	
		save(sprintf('%s%s_stage%d_i1vx_0.mat',resultdir,prefix,stage),'i1vx');
		save(sprintf('%s%s_stage%d_i2vx_0.mat',resultdir,prefix,stage),'i2vx');
		save(sprintf('%s%s_stage%d_mvs_0.mat',resultdir,prefix,stage),'mvx','mvy','mvz');
	end
	guisecs = guisecs + (cputime-ctg);

	for pass = 1:passes_in_stage(real_stage)
		ct2 = cputime;
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d, pass %d of %d - Computing motion field ...', stage,pass,passes_in_stage(real_stage)));
		else
			figure(H);waitbar(0,H,sprintf('stage %d, pass %d of %d - Computing motion field ...', stage,pass,passes_in_stage(real_stage)));
		end
		fprintf('Computing motion: stage %d - pass %d\n', stage, pass);
		
		ctc = cputime;
		maxiter = maxiters(real_stage);
		fprintf('With reverse consistency: \n');
		[mvy1,mvx1,mvz1] = reg_method_dispatch_inverse_consistency(method,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,smoothing_settings);
		fprintf('Motion computation stage %d,%d is finished\n',stage,pass);
		
		if check_motion_vector_magnitude == 1
			if stage < stages
				[mvx1,mvy1,mvz1]=Limit_Magnitude(mvx1,mvy1,mvz1,maxmotion);
			end
		end

		if smoothing_settings(2) > 0
			% Extra smoothing
			disp('Extra smoothing the delta motion fields ...');
			mvy1 = lowpass3d(mvy1,smoothing_settings(2)/real_stage);
			mvx1 = lowpass3d(mvx1,smoothing_settings(2)/real_stage);
			mvz1 = lowpass3d(mvz1,smoothing_settings(2)/real_stage);
		end
		
		% Save the results
		% Generate the output
		
		delta_mvy = mvy;
		delta_mvx = mvx;
		delta_mvz = mvz;
		
		disp('Computing result motion field for this pass by interpolating ...');
		[mvy,mvx,mvz] = compose_motion_field(mvy,mvx,mvz,mvy1,mvx1,mvz1);
		[imvy,imvx,imvz] = compose_motion_field(imvy,imvx,imvz,-mvy1,-mvx1,-mvz1);

		if compute_reverse_motion_by_integration == 1
			% double sampling the forward motion fields
			[mvyf,mvxf,mvzf] = compose_forward_motion_field(mvyf,mvxf,mvzf,-mvy1,-mvx1,-mvz1);
			[imvyf,imvxf,imvzf] = compose_forward_motion_field(imvyf,imvxf,imvzf,mvy1,mvx1,mvz1);
		end

		if smoothing_settings(3) > 0
			% Extra smoothing
			disp('Diffusing the motion fields of this stage ...');
			mvy = lowpass3d(mvy,smoothing_settings(3)/real_stage);
			mvx = lowpass3d(mvx,smoothing_settings(3)/real_stage);
			mvz = lowpass3d(mvz,smoothing_settings(3)/real_stage);
			imvy = lowpass3d(imvy,smoothing_settings(3)/real_stage);
			imvx = lowpass3d(imvx,smoothing_settings(3)/real_stage);
			imvz = lowpass3d(imvz,smoothing_settings(3)/real_stage);

			if compute_reverse_motion_by_integration == 1
				mvyf = lowpass3d(mvyf,smoothing_settings(3)/real_stage);
				mvxf = lowpass3d(mvxf,smoothing_settings(3)/real_stage);
				mvzf = lowpass3d(mvzf,smoothing_settings(3)/real_stage);
				imvyf = lowpass3d(imvyf,smoothing_settings(3)/real_stage);
				imvxf = lowpass3d(imvxf,smoothing_settings(3)/real_stage);
				imvzf = lowpass3d(imvzf,smoothing_settings(3)/real_stage);
			end
		end
		
		delta_mvy = delta_mvy - mvy;
		delta_mvx = delta_mvx - mvx;
		delta_mvz = delta_mvz - mvz;
		delta_mvs = sqrt(delta_mvy.^2+delta_mvx.^2+delta_mvz.^2);
		max_delta_mvs = max(delta_mvs(:));
		mean_delta_mvs = mean(delta_mvs(:));
		clear delta_mvy delta_mvx delta_mvz delta_mvs;
		
		
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Computing the moved image ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Computing the moved image ...', stage));
		end
		
		disp('Computing moved image by interpolating ...');
 		i1vx = move3dimage(single(im1),mvy,mvx,mvz);
 		i2vx = move3dimage(single(im2),imvy,imvx,imvz);

		disp('Computing moved image is finished');
		calsecs = calsecs + (cputime-ctc);

		ctg=cputime;
		if mod(save_results,2) == 1
			if ~isempty(mainfigure)
				set(mainfigure,'Name',sprintf('stage %d - Saving i1vx and motion delta vectors ...', stage));
			else
				figure(H);waitbar(0,H,sprintf('stage %d - Saving i1vx and motion delta vectors ...', stage));
			end

			save(sprintf('%s%s_stage%d_%d_i1vx.mat',resultdir,prefix,stage,pass),'i1vx');
			save(sprintf('%s%s_stage%d_%d_i2vx.mat',resultdir,prefix,stage,pass),'i2vx');
			save(sprintf('%s%s_stage%d_%d_dmvs.mat',resultdir,prefix,stage,pass),'mvx1','mvy1','mvz1');
		end
		clear mvx1 mvy1 mvz1;
		
		if( ~isempty(mainfigure) )
			set(mainfigure,'Name',sprintf('stage %d - Updating GUI ...', stage));
			handles = guidata(mainfigure);
			handles.images(1).image_deformed = i1vx;
			handles.images(2).image_deformed = i2vx;
			
			if isfield(handles.reg,'true_mvx')
				% convergence study
				[mvyt,mvxt,mvzt]= invert_motion_field_smart(imvy,imvx,imvz,1);
				mvyt(isnan(mvyt))=0;
				mvxt(isnan(mvxt))=0;
				mvzt(isnan(mvzt))=0;

				[mvyt,mvxt,mvzt] = compose_motion_field(mvy,mvx,mvz,mvyt,mvxt,mvzt);
				erx = handles.reg.true_mvx - mvxt;
				ery = handles.reg.true_mvy - mvyt;
				erz = handles.reg.true_mvz - mvzt;
				ers = sqrt(erx.^2+ery.^2+erz.^2);

				if ndims(erx) == 3
					maskt = abs(handles.reg.true_mvx)>0.05 & abs(handles.reg.true_mvy)>0.05 & abs(handles.reg.true_mvz)>0.05;
				else
					maskt = abs(handles.reg.true_mvx)>0.05 & abs(handles.reg.true_mvy)>0.05;
				end

				ers = ers.*maskt;
				
				if pass == 1 && isfield(handles.reg,'mean_ers')
					handles.reg = rmfield(handles.reg,'mean_ers');
					clear mean_delta_passs mean_ssd;
				end
				
				handles.reg.mean_ers(pass) = mean(ers(:));
				mean_delta_passs(pass) = mean_delta_mvs;
				assignin('base','mean_ers',handles.reg.mean_ers);
				assignin('base','mean_delta',mean_delta_passs);

				ers = i1vx - i2vx; mean_ssd(pass) = mean(abs(ers(:)));
				assignin('base','mean_ssd',mean_ssd);

				clear erx ery erz ers mvyt mvxt mvzt maskt;
				
			end
			
			guidata(mainfigure,handles);
			RefreshDisplay(handles);
			
			clear handles;
		end
		
		i1vx2 = i1vx;
		i2vx2 = i2vx;
		
		[MI,NMI,MI3,CC,CC2,COV,MSE] = images_info(i1vx2,i2vx2,'MI','NMI','MI3','CC','CC2','cOV','MSE');
		fprintf('stage %d,%d, MI = %d\n',stage, pass, MI);
		fprintf('stage %d,%d, NMI = %d\n',stage, pass, NMI);
		fprintf('stage %d,%d, MI3 = %d\n',stage, pass, MI3);
		fprintf('stage %d,%d, CC = %d\n',stage, pass, CC);
		fprintf('stage %d,%d, CC2 = %d\n',stage, pass, CC2);
		fprintf('stage %d,%d, COV = %d\n',stage, pass, COV);
		fprintf('stage %d,%d, MSE = %d\n',stage, pass, MSE);

		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d,%d - Finished', stage,pass));
		else
			figure(H);waitbar(1,H,sprintf('stage %d,%d - Finished', stage,pass));
		end
		guisecs = guisecs + (cputime-ctg);

		fprintf('This pass used %.2f seconds to finish.\n\n',cputime-ct2);

		abortflag = CheckAbortPauseButtons(mainfigure,1);
		if abortflag >= 1
			break;	% break out off the pass
		end

		if ~any(method == [1:9 11 12 15 17 18 22 23 24]) % Iterative methods do not need multiple passs
			break;	% Don't pass here
		end
		
		%Check the motion field update for this pass
		fprintf('Motion in this pass: mean = %d, max = %d\n\n\n',mean_delta_mvs,max_delta_mvs);
		if max_delta_mvs < stop2
			disp('Max motion in stage is too small, stop this stages now');
			break;
		end
	end
	
	
	if smoothing_settings(4) > 0
		% Extra smoothing
		disp('Extra smoothing the motion fields ...');
		mvy = lowpass3d(mvy,smoothing_settings(4)/real_stage);
		mvx = lowpass3d(mvx,smoothing_settings(4)/real_stage);
		mvz = lowpass3d(mvz,smoothing_settings(4)/real_stage);
		imvy = lowpass3d(imvy,smoothing_settings(4)/real_stage);
		imvx = lowpass3d(imvx,smoothing_settings(4)/real_stage);
		imvz = lowpass3d(imvz,smoothing_settings(4)/real_stage);

		if compute_reverse_motion_by_integration == 1
			mvyf = lowpass3d(mvyf,smoothing_settings(4)/real_stage);
			mvxf = lowpass3d(mvxf,smoothing_settings(4)/real_stage);
			mvzf = lowpass3d(mvzf,smoothing_settings(4)/real_stage);
			imvyf = lowpass3d(imvyf,smoothing_settings(4)/real_stage);
			imvxf = lowpass3d(imvxf,smoothing_settings(4)/real_stage);
			imvzf = lowpass3d(imvzf,smoothing_settings(4)/real_stage);
		end
	end
	
	if mod(save_results,2) == 1
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Saving output mvs files ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Saving output mvs files ...', stage));
		end
		save(sprintf('%s%s_stage%d_mvs.mat',resultdir,prefix,stage),'mvx','mvy','mvz');
		
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Saving i1vx ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Saving i1vx ...', stage));
		end
		save(sprintf('%s%s_stage%d_i1vx.mat',resultdir,prefix,stage),'i1vx');
		save(sprintf('%s%s_stage%d_i2vx.mat',resultdir,prefix,stage),'i2vx');
	end
	
	clear i1vx i2vx;
	
	if ~isempty(mainfigure)
		set(mainfigure,'Name',sprintf('stage %d - Finished', stage));
	else
		figure(H);waitbar(1,H,sprintf('stage %d - Finished', stage));
	end

	fprintf('\nstage %d is finished, used %.2f seconds.\n\n\n',stage,cputime-ct1);
	
% 	if abortflag == 1
% 		disp('Aborted per user request');
% 		break;	% Break out off the stage
% 	end
	
	lastStage = real_stage;
end

if isempty(mainfigure)
	close(H);
end

% Compute final motion field
disp('Computing final motion field ...');

mvy0 = mvy;
mvx0 = mvx;
mvz0 = mvz;
imvy0 = imvy;
imvx0 = imvx;
imvz0 = imvz;

if compute_reverse_motion_by_integration == 0
	disp('Checking Jacobian values ...');
	jac1 = motion_field_jacobian(mvy0,mvx0,mvz0); jac = jac1(:);
	fprintf('Jacobian for image #1: mean = %d, std = %d, min = %d, max = %d\n',mean(jac),std(jac),min(jac),max(jac));
	jac2 = motion_field_jacobian(imvy0,imvx0,imvz0); jac = jac2(:);
	fprintf('Jacobian for image #1: mean = %d, std = %d, min = %d, max = %d\n',mean(jac),std(jac),min(jac),max(jac));
	clear jac jac1 jac2;
	
	disp('Inverting motion field 1 ...');
	ci0 = cputime;
% 	[imvyt,imvxt,imvzt]=invert_motion_field(imvy0,imvx0,imvz0);
	[imvyt,imvxt,imvzt]= invert_motion_field_smart(imvy0,imvx0,imvz0,1);
	fprintf('Inverting motion field used %.3g seconds\n',cputime-ci0);
	imvyt(isnan(imvyt))=0;
	imvxt(isnan(imvxt))=0;
	imvzt(isnan(imvzt))=0;

	% disp('Compute motion field reversing error ...');
	% erx = -mvx + move3dimage(imvx,mvy,mvx,mvz);
	% ery = -mvy + move3dimage(imvy,mvy,mvx,mvz);
	% erz = -mvz + move3dimage(imvz,mvy,mvx,mvz);
	% erabs = sqrt(erx.*erx+ery.*ery+erz.*erz);
	% fprintf('Abs(error): x - %d, y - %d, z - %d, magnitude - %d\n',mean(abs(erx(:))),mean(abs(ery(:))),mean(abs(erz(:))),mean(erabs(:)));
	% clear erx ery erz erabs;

	disp('Computing forward motion field ...');
	ci0 = cputime;

	[mvy,mvx,mvz] = compose_motion_field(mvy0,mvx0,mvz0,imvyt,imvxt,imvzt);
	fprintf('Computing forward motion used %.3g seconds\n',cputime-ci0);

	clear imvyt imvxt imvzt;

	if ~isempty(mainfigure)
		handles = guidata(mainfigure);
		if handles.reg.Generate_Reverse_Consistent_Motion_Field == 1
			disp('Inverting motion field 2 ...');

			ci0 = cputime;
% 			[imvy2,imvx2,imvz2]=invert_motion_field(mvy0,mvx0,mvz0);
			[imvy2,imvx2,imvz2]=invert_motion_field_smart(mvy0,mvx0,mvz0,1);
			fprintf('Inverting motion field used %.3g seconds\n',cputime-ci0);

			imvy2(isnan(imvy2))=0;
			imvx2(isnan(imvx2))=0;
			imvz2(isnan(imvz2))=0;

			% 		handles.reg.idvf.y = -2*imvy2;
			% 		handles.reg.idvf.x = -2*imvx2;
			% 		handles.reg.idvf.z = -2*imvz2;

			disp('Computing backward motion field ...');
			ci0 = cputime;
			% 		handles.reg.idvf.y = imvy2 + move3dimage(imvy0,imvy2,imvx2,imvz2)/2;
			% 		handles.reg.idvf.x = imvx2 + move3dimage(imvx0,imvy2,imvx2,imvz2)/2;
			% 		handles.reg.idvf.z = imvz2 + move3dimage(imvz0,imvy2,imvx2,imvz2)/2;
			[handles.reg.idvf.y,handles.reg.idvf.x,handles.reg.idvf.z] = compose_motion_field(imvy0,imvx0,imvz0,imvy2,imvx2,imvz2);
			handles = FillDVFInfo(handles,3);
			fprintf('Computing backward motion used %.3g seconds\n',cputime-ci0);

			clear imvy2 imvx2 imvz2
			guidata(mainfigure,handles);
		end
	end
else
	[mvy,mvx,mvz] = compose_motion_field(mvy0,mvx0,mvz0,imvyf,imvxf,imvzf);
	if ~isempty(mainfigure)
		handles = guidata(mainfigure);
		if handles.reg.Generate_Reverse_Consistent_Motion_Field == 1
			[handles.reg.idvf.y,handles.reg.idvf.x,handles.reg.idvf.z] = compose_motion_field(imvy0,imvx0,imvz0,mvyf,mvxf,mvzf);
			handles = FillDVFInfo(handles,3);
			guidata(mainfigure,handles);
		end
	end
end

disp('Compute deformed image 1 ...');
i1vx = move3dimage(single(im1), mvy, mvx, mvz);

if mod(save_results,2) == 1
	save(sprintf('%s%s_final_mvs.mat',resultdir,prefix),'mvx','mvy','mvz');
end

if ~isempty(mainfigure)
	handles = guidata(mainfigure);
	handles.images(1).image_deformed = i1vx;
	handles.reg.dvf.x = mvx;
	handles.reg.dvf.y = mvy;
	handles.reg.dvf.z = mvz;
	handles = FillDVFInfo(handles,3);
	handles.images(2).image_deformed = [];
	guidata(mainfigure,handles);
	RefreshDisplay(handles);
end

disp('All finished');
fprintf('It took %.2f seconds to finish the entire multigrid registration\n',cputime-ct0);
fprintf('It took %.2f seconds with GUI\n',guisecs);
fprintf('It took %.2f seconds with actually computation\n',calsecs);

diary off;
handles = guidata(mainfigure);
set(mainfigure,'Name',[handles.info.name ' - Ready']);

return;


function [mvx,mvy,mvz]=Limit_Magnitude(mvx,mvy,mvz,thres)
% This step will restrict the magnitude of the motion field
% in the earlier steps to be less than threshold. Such a
% restriction will help to solve the outlier and errors
% near the boundaries
mv = sqrt(mvx.^2+mvy.^2+mvz.^2);
if max(mv(:)) <= thres
	return;
end

mv2 = min(mv,thres);
factor = mv2 ./ (mv + (mv == 0 ));
mvx = mvx .* factor;
mvy = mvy .* factor;
mvz = mvz .* factor;

return;

% function [mvx,mvy,mvz]=CheckMagnitude2(mvx,mvy,mvz)
% % This step will reduce the magnitude of the motion field
% % in the earlier steps if the motion could be recovered in
% % later multigrid steps
% mv = sqrt(mvx.^2+mvy.^2+mvz.^2);
% mv2 = (mv - 0.4) .* (mv > 0.4);
% factor = mv2 ./ (mv + (mv == 0 ));
% mvx = mvx .* factor;
% mvy = mvy .* factor;
% mvz = mvz .* factor;
% clear mv mv2 factor;
% return;

