function [mvy,mvx,mvz,i1vx]=multigrid_7(method,img1,img2,structure_masks,voxelsize_ratio,stages,startingstage,mainfigure,save_results,resultdir,prefix,smoothing_settings,intensity_modulation,filter_type)
%
% The multi-grid framework, runs from the GUI
% Usage:
%	[mvy,mvx,mvz,i1vx]=multigrid_7(method,img1,img2,
%           voxelsize_ratio,stages,startingstage,mainfigure,save_results,
%           resultdir,prefix,smoothing_settings,intensity_modulation,filter_type)
%
%	If the mainfigure is empty, there will be only command line message	outputs
%	If the resultdir is omitted or empty, results will be saved in the
%	current folder
%
% Changes:
%
% Version 4
% In coarse level, if the motion vector magnitude is less than 0.4, then
% set it to 0 because we could safely recover it in the finer level
%
% Version 5 : Try to fix the errors near the boundaries in the earlier
% stages
% - Limit the motion vector amplitude (<1) for each stage
% - Limit the motion vector amplitude (<1) for each pass within the stage
% - Apply multiple passes for each earlier stage so that the motion field is
%   increasing gratually and under control
% - Save delta motion field for each pass and for each stage
% - Save images in PNG (after maximizing the figure window)
%
% Version 6: Be able to run with or without GUI
%
% If calling from GUI, all input parameters could be left empty
% If calling from command line, then the first 3 parameters needs to be
% given.
%
% Version 7: Now doing only 4 stages instead of 5 stages
%			 or doing configuration number of stages
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

setpath;

interpolation_filter = 'linear';
% interpolation_filter = 'cubic';


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

if ~exist('smoothing_settings','var') || isempty(smoothing_settings)
	smoothing_settings = [3 0];
end

if ~exist('filter_type','var') || isempty(filter_type)
	filter_type = 1;
end

smoothing_settings = [smoothing_settings 0 0 0];

% Options
maxmotion = 0.4;
check_motion_vector_magnitude = 1;
% check_motion_vector_magnitude = 0;


% User select image filenames

if( ~exist('voxelsize_ratio','var') || isempty(voxelsize_ratio) )
	voxelsize_ratio = InputImageVoxelSizeRatio();
end
voxelsize_ratio = voxelsize_ratio / min(voxelsize_ratio);

if ~exist('save_results','var')
	save_results = 0;
end

if save_results >= 1
	if ~exist('resultdir','var') || isempty(resultdir)
		resultdir = uigetdir('', 'Select a working folder to save intermediate files, log files and results');
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
	set(H,'Name','Multigrid Regular');
	set(H,'NumberTitle','off');
end

fprintf('\n\nMultigrid Regular\n\n\n');

if stages > 1
	[img1_2,img1_4,img1_8,img2_2,img2_4,img2_8]=Multigrid_Downsample_All(filter_type,img1,img2,[],min(stages,4),~isempty(mainfigure));
end

if stages > 4
	img1_16 = GPReduce(img1_8);
	img2_16 = GPReduce(img2_8);
end

if ~isempty(structure_masks)
	disp('Down sampling the structure masks');
	structure_masks_2 = round(MeanReduce(structure_masks));
	structure_masks_4 = round(MeanReduce(structure_masks_2));
	structure_masks_8 = round(MeanReduce(structure_masks_4));
	if stages > 4
		structure_masks_16 = round(MeanReduce(structure_masks_8));
	end
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

image_offsets = [0 0 0];
if ~isempty(mainfigure)
	handles = guidata(mainfigure);
	handles = Clear_Results(handles);

	image_infos{1} = GenerateMultigridImageInfo(handles.images(1));
	image_infos{2} = GenerateMultigridImageInfo(handles.images(2));
	
	image_offsets = handles.reg.images_setting.image_offsets;
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
	structure_masks_this_stage = [];
	switch real_stage
		case 5
			im1 = img1_16;
			im2 = img2_16;
			if ~isempty(structure_masks)
				structure_masks_this_stage = structure_masks_16;
			end
		case 4
			im1 = img1_8;
			im2 = img2_8;
			if ~isempty(structure_masks)
				structure_masks_this_stage = structure_masks_8;
			end
		case 3
			im1 = img1_4;
			im2 = img2_4;
			if ~isempty(structure_masks)
				structure_masks_this_stage = structure_masks_4;
			end
		case 2
			im1 = img1_2;
			im2 = img2_2;
			if ~isempty(structure_masks)
				structure_masks_this_stage = structure_masks_2;
			end
		case 1
			im1 = img1;
			im2 = img2;
			if ~isempty(structure_masks)
				structure_masks_this_stage = structure_masks;
			end
	end
	
	structure_masks_this_stage_deformed = structure_masks_this_stage;
	
	
	im1 = single(im1);
	im2 = single(im2);

	dim1 = mysize(im1);
	dim2 = mysize(im2);
	
	% Perform intensity remapping to boost low intensity
	
	% Initialze motion fields
	ctc = cputime;
	image_current_offsets = floor(image_offsets / (2^(real_stage-1)));
% 	ys = (1:dim2(1))+image_current_offsets(1);
% 	xs = (1:dim2(2))+image_current_offsets(2);
% 	zs = (1:dim2(3))+image_current_offsets(3);
	
	if( stage == 1 )
		fprintf('Initialize motion fields\n');
		mvy = zeros(dim2,'single');
		mvx = zeros(dim2,'single');
		mvz = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		i1vx = im1;
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
		if isequal(dim1,dim2)
			i1vx = move3dimage(im1,mvy,mvx,mvz,interpolation_filter,image_current_offsets,intensity_modulation);
		else
			[mvyL,mvxL,mvzL] = expand_motion_field(mvy,mvx,mvz,dim1,image_current_offsets);
			i1vx = move3dimage(im1,mvyL,mvxL,mvzL,interpolation_filter,[],intensity_modulation);
			clear mvyL mvxL mvzL;
		end
		
		temp = i1vx;
		i1vx = max(i1vx,0);
		i1vx(isnan(temp)) = nan;
		clear temp;
		
		disp('Computing moved image is finished');		
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
		handles.images(1).image = im1;
		handles.images(2).image = im2;
		handles.images(1).voxelsize = image_infos{1}(real_stage).voxelsize;
		handles.images(1).origin = image_infos{1}(real_stage).origin;
		handles.images(2).voxelsize = image_infos{2}(real_stage).voxelsize;
		handles.images(2).origin = image_infos{2}(real_stage).origin;
		handles.reg.dvf.x = mvx;
		handles.reg.dvf.y = mvy;
		handles.reg.dvf.z = mvz;
		handles = FillDVFInfo(handles,1);
		handles.reg.images_setting.image_current_offsets = image_current_offsets;
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
	end

	if mod(save_results,2) == 1
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d - Saving initial variables ...', stage));
		else
			figure(H);waitbar(0,H,sprintf('stage %d - Saving initial variables ...', stage));
		end
	
		save(sprintf('%s%s_stage%d_i1vx_0.mat',resultdir,prefix,stage),'i1vx');
		save(sprintf('%s%s_stage%d_mvs_0.mat',resultdir,prefix,stage),'mvx','mvy','mvz');
	end
	guisecs = guisecs + (cputime-ctg);

	Numpasses = passes_in_stage(real_stage);
	if ~any(method == [1:9 11 12 15 17 18 22 23 24]) % Iterative methods do not need multiple passes
		Numpasses = 1;	% Don't pass here
	elseif abortflag == 1
		Numpasses = 0;
	end

	for pass = 1:Numpasses
		ct2 = cputime;
		if ~isempty(mainfigure)
			set(mainfigure,'Name',sprintf('stage %d.%d(%d) - Computing motion field ...', stage,pass,Numpasses));
		else
			figure(H);waitbar(0,H,sprintf('stage %d.%d(%d) - Computing motion field ...', stage,pass,Numpasses));
		end
		fprintf('Computing motion: stage %d - pass %d\n', stage, pass);
		
		ctc = cputime;
		if method ~= 9 && method ~= 12
			[mvy1,mvx1,mvz1] = reg_method_dispatch(method,mainfigure,i1vx,im2,structure_masks_this_stage_deformed,voxelsize_ratio,maxiters(real_stage),stop,[],[],[],image_current_offsets,smoothing_settings(1));
		else
			if pass == 1
				[mvy1,mvx1,mvz1] = reg_method_dispatch(method,mainfigure,i1vx,im2,structure_masks_this_stage_deformed,voxelsize_ratio,maxiters(real_stage),stop,mvy,mvx,mvz,image_current_offsets,smoothing_settings(1));
			else
				[mvy1,mvx1,mvz1] = reg_method_dispatch(method,mainfigure,i1vx,im2,structure_masks_this_stage_deformed,voxelsize_ratio,maxiters(real_stage),stop,mvy + mvy_this_stage,mvx + mvx_this_stage,mvz + mvz_this_stage,image_current_offsets,smoothing_settings(1));
			end
		end
		
		fprintf('Motion computation stage %d,%d is finished\n',stage,pass);
		
		if check_motion_vector_magnitude == 1
			if stage < stages
				[mvx1,mvy1,mvz1]=Limit_Magnitude(mvx1,mvy1,mvz1,maxmotion);
			end
		end
		
		if smoothing_settings(2) > 0
			disp('Extra smoothing the delta motion fields ...');
			[mvy1,mvx1,mvz1] = smooth_motion_field(mvy1,mvx1,mvz1,smoothing_settings(2)/real_stage);
		end
		
		% Save the results
		% Generate the output
		delta_mvy = mvy;
		delta_mvx = mvx;
		delta_mvz = mvz;

		disp('Computing result motion field for this pass by interpolating ...');
		[mvy,mvx,mvz] = compose_motion_field(mvy,mvx,mvz,mvy1,mvx1,mvz1,dim1,image_current_offsets);

		if smoothing_settings(3) > 0
			fprintf('Smoothing the motion field, kernel size = %d: mvy',smoothing_settings(2));
			[mvy,mvx,mvz] = smooth_motion_field(mvy,mvx,mvz,smoothing_settings(3)/real_stage);
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
		if isequal(dim1,dim2)
			i1vx = move3dimage(im1,mvy,mvx,mvz,interpolation_filter,image_current_offsets,intensity_modulation);
		else
			[mvyL,mvxL,mvzL] = expand_motion_field(mvy,mvx,mvz,dim1,image_current_offsets);
			i1vx = move3dimage(im1,mvyL,mvxL,mvzL,interpolation_filter,[],intensity_modulation);
			clear mvyL mvxL mvzL;
		end

		temp = i1vx;
		i1vx = max(i1vx,0);
		i1vx(isnan(temp)) = nan;
		clear temp;

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
			save(sprintf('%s%s_stage%d_%d_dmvs.mat',resultdir,prefix,stage,pass),'mvx1','mvy1','mvz1');
% 			save(sprintf('%s%s_stage%d_%d_stage_mvs.mat',resultdir,prefix,stage,pass),'mvx_this_stage','mvy_this_stage','mvz_this_stage');
		end
		clear mvx1 mvy1 mvz1;
		
		if( ~isempty(mainfigure) )
			if ~isempty(mainfigure)
				set(mainfigure,'Name',sprintf('stage %d - Updating GUI ...', stage));
			else
				figure(H);waitbar(0,H,sprintf('stage %d - Updating GUI ...', stage));
			end
			handles = guidata(mainfigure);
			handles.images(1).image_deformed = i1vx;
			
			handles.reg.dvf.y = mvy;
			handles.reg.dvf.x = mvx;
			handles.reg.dvf.z = mvz;
			handles = FillDVFInfo(handles,1);
			
% 			if isfield(handles.reg,'true_mvx')
% 				[mvyt,mvxt,mvzt] = compose_motion_field(mvy,mvx,mvz,mvy_this_stage,mvx_this_stage,mvz_this_stage);
% 				erx = handles.reg.true_mvx - mvxt;
% 				ery = handles.reg.true_mvy - mvyt;
% 				erz = handles.reg.true_mvz - mvzt;
% 				ers = sqrt(erx.^2+ery.^2+erz.^2);
% % 				ers = i1vx-im2; ers = mean(abs(ers(:)));
% 				if ndims(erx) == 3
% 					maskt = abs(handles.reg.true_mvx)>0.05 & abs(handles.reg.true_mvy)>0.05 & abs(handles.reg.true_mvz)>0.05;
% 				else
% 					maskt = abs(handles.reg.true_mvx)>0.05 & abs(handles.reg.true_mvy)>0.05;
% 				end
% 				ers = ers.*maskt;
% 				
% 				if pass == 1 && isfield(handles.reg,'mean_ers')
% 					handles.reg = rmfield(handles.reg,'mean_ers');
% 					clear mean_delta_passs mean_ssd;
% 				end
% 				
% 				handles.reg.mean_ers(pass) = mean(ers(:));
% 				mean_delta_passs(pass) = mean_delta_mvs;
% 				
%  				ers = i1vx-im2; mean_ssd(pass) = mean(abs(ers(:)));
% 				
% 				assignin('base','mean_ers',handles.reg.mean_ers);
% 				assignin('base','mean_delta',mean_delta_passs);
% 				assignin('base','mean_ssd',mean_ssd);
% 				clear erx ery erz ers mvyt mvxt mvzt maskt;
% 			end
			

			guidata(mainfigure,handles);
			RefreshDisplay(handles);
			clear handles;
		end
		
		if ~isequal(dim1,dim2)
			i1vx2 = i1vx((1:dim2(1))+image_current_offsets(1),(1:dim2(2))+image_current_offsets(2),(1:dim2(3))+image_current_offsets(3));
		else
			i1vx2 = i1vx;
		end
		
		[MI,NMI,MI3,CC,CC2,COV,MSE] = images_info(i1vx2,im2,'MI','NMI','MI3','CC','CC2','cOV','MSE');
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
		
		%Check the motion field update for this pass
		fprintf('Motion in this pass: mean = %d, max = %d\n\n\n',mean_delta_mvs,max_delta_mvs);
		if max_delta_mvs < stop2
			disp('Max motion in stage is too small, stop this stages now');
			break;
		end

		abortflag = CheckAbortPauseButtons(mainfigure,1);
		if abortflag >= 1
			break;	% break out off the pass
		end
	end

	if smoothing_settings(4) > 0
		fprintf('Smoothing the motion field, kernel size = %d: mvy',smoothing_settings(2));
		
		if isempty(structure_masks)
			[mvy,mvx,mvz] = smooth_motion_field(mvy,mvx,mvz,smoothing_settings(4)/real_stage);
		else
			smoothing_settings2 = ones(1,max(structure_masks(:))+1)*smoothing_settings(4);
			mvy = lowpass3d_piecewise_smoothing(mvy,smoothing_settings2/real_stage,structure_masks_this_stage);
			fprintf(',mvx');
			mvx = lowpass3d_piecewise_smoothing(mvx,smoothing_settings2/real_stage,structure_masks_this_stage);
			fprintf(',mvz');
			mvz = lowpass3d_piecewise_smoothing(mvz,smoothing_settings2/real_stage,structure_masks_this_stage);
			fprintf('\n');
		end
	end

	clear mvx_this_stage mvy_this_stage mvz_this_stage;
	
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
	end
	
	clear i1vx;
	
	if ~isempty(mainfigure)
		set(mainfigure,'Name',sprintf('stage %d - Finished', stage));
	else
		figure(H);waitbar(1,H,sprintf('stage %d - Finished', stage));
	end

	fprintf('\nstage %d is finished, used %.2f seconds.\n\n\n',stage,cputime-ct1);
	
	lastStage = real_stage;
end

if ~isempty(mainfigure)
	handles = guidata(mainfigure);
	handles.reg.dvf.x = mvx;
	handles.reg.dvf.y = mvy;
	handles.reg.dvf.z = mvz;
	handles = FillDVFInfo(handles,1);
	guidata(mainfigure,handles);
	RefreshDisplay(handles);
else
	close(H);
end

if mod(save_results,2) == 1
	save(sprintf('%s%s_final_mvs.mat',resultdir,prefix),'mvx','mvy','mvz');
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
mv = sqrt(mvx.^2+mvy.^2+mvz.^2);
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
% return;

% function vol2 = subvol(vol,dim,offset)
% 	ys = (1:dim(1))+offset(1);
% 	xs = (1:dim(2))+offset(2);
% 	zs = (1:dim(3))+offset(3);
% 	vol2 = vol(ys,xs,zs);
% return;

function [mvy,mvx,mvz] = smooth_motion_field(mvy,mvx,mvz,kernelsize)
	mvy = lowpass3d(mvy,kernelsize);
	mvx = lowpass3d(mvx,kernelsize);
	mvz = lowpass3d(mvz,kernelsize);
return;


