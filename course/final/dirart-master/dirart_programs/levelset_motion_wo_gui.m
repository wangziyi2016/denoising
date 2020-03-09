% function [mvy,mvx,mvz,i1vx]=levelset_motion_wo_gui(im1,im2,voxelsizes,step,mainfigure,im1ori,mvyori,mvxori,mvzori,resultdir)
function [mvy,mvx,mvz,i1vx]=levelset_motion_wo_gui(im1,im2,voxelsizes,step,mainfigure) %,im1ori,mvyori,mvxori,mvzori,resultdir)
%{
Levelset deformable registration method without GUI.


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

% Motion models:	global-affine,	local-affine,	spline, local-free-deformation
motion_models = [ 1 1 1 1; 0 1 1 1; 0 1 1 1; 0 1 1 1];

maxiters = [30 15 20 20;10 10 20 15;5 5 20 15;5 5 10 15];
factors = [2 1 0.5 0.5;1 1 0.5 0.5;1 1 1 0.5;1 1 1 0.5];	% delta_t factors
stops = [1e-2 5e-3 1e-3 5e-4;1e-2 5e-3 1e-3 5e-4;1e-2 5e-3 1e-3 1e-3;1e-2 5e-3 1e-3 1e-3];

LocalAffineBlockSize = [8 8 8];
spline_smoothing_block_sizes = [5 5 5];
lowpass_kernal_size = [3 3 3];


dim = size(im2);
mvy = zeros(dim,'single');
mvx = zeros(dim,'single');
mvz = zeros(dim,'single');

models = squeeze(motion_models(step,:));

if ~isempty(mainfigure)
	figureTitle = get(mainfigure,'Name');
end

if models(1) == 1
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle ' - Global Affine Approximation']);
		drawnow;
	end
	disp(sprintf('Global affine approximation for step %d',step));
	[mvy,mvx,mvz] = levelset_motion_global_affine(mainfigure,im1,im2,factors(step,1),maxiters(step,1),stops(step,1));
	%[mvy,mvx,mvz] = levelset_motion_global_affine_wo_gui(im1,im2,factors(step,1),maxiters(step,1),stops(step,1));
	disp('Moving 3D images after global affine approximation');
% 	if ~isempty(mainfigure)
% 		disp('Updating GUI');
% 		mvyori2 = move3dimage(mvyori,mvy,mvx,mvz,'linear') + mvy;
% 		mvxori2 = move3dimage(mvxori,mvy,mvx,mvz,'linear') + mvx;
% 		mvzori2 = move3dimage(mvzori,mvy,mvx,mvz,'linear') + mvz;
% 		i1vx = move3dimage(im1ori,mvyori2,mvxori2,mvzori2);
% 		UpdateGUI(mainfigure,mvyori2,mvxori2,mvzori2,mvy,mvx,mvz,i1vx);
% 		
% 		if ~exist('resultdir','var') && ~isempty(resultdir)
% 			save(sprintf('%sstep%d_after_global_affine_i1vx.mat',resultdir,step),'i1vx');
% 			save(sprintf('%sstep%d_after_global_affine_mvs.mat',resultdir,step),'mvx','mvy','mvz');
% 		end
% 		
% 	else
		i1vx = move3dimage(im1,mvy,mvx,mvz);
% 	end
end

abortflag = CheckAbortPauseButtons(mainfigure,0);
if abortflag > 0
	return;	% break out off the loop
end


if models(2) == 1
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle ' - Local Affine Approximation']);
		drawnow;
	end
	if models(1) == 1
		disp(sprintf('Local affine approximation for step %d',step));
		[mvy1,mvx1,mvz1] = levelset_motion_local_affine(mainfigure,i1vx,im2,factors(step,2),...
			maxiters(step,2),stops(step,2),LocalAffineBlockSize,[],lowpass_kernal_size);
		disp('Computing motion concatenation after local affine approximation ...');
		disp('Computing motion mvy ...');
		mvy = move3dimage(mvy,mvy1,mvx1,mvz1,'linear') + mvy1;
		disp('Computing motion mvx ...');
		mvx = move3dimage(mvx,mvy1,mvx1,mvz1,'linear') + mvx1;
		disp('Computing motion mvz ...');
		mvz = move3dimage(mvz,mvy1,mvx1,mvz1,'linear') + mvz1;
	else
		disp(sprintf('Local affine approximation for step %d',step));
		[mvy,mvx,mvz] = levelset_motion_local_affine(mainfigure,im1,im2,factors(step,2),...
			maxiters(step,2),stops(step,2),LocalAffineBlockSize,[],lowpass_kernal_size);
	end
	disp('Moving 3D images after local affine approximation');
% 	if ~isempty(mainfigure)
% 		disp('Updating GUI');
% 		mvyori2 = move3dimage(mvyori,mvy,mvx,mvz,'linear') + mvy;
% 		mvxori2 = move3dimage(mvxori,mvy,mvx,mvz,'linear') + mvx;
% 		mvzori2 = move3dimage(mvzori,mvy,mvx,mvz,'linear') + mvz;
% 		i1vx = move3dimage(im1ori,mvyori2,mvxori2,mvzori2);
% 		UpdateGUI(mainfigure,mvyori2,mvxori2,mvzori2,mvy,mvx,mvz,i1vx);
% 		
% 		if ~exist('resultdir','var') && ~isempty(resultdir)
% 			save(sprintf('%sstep%d_after_local_affine_i1vx.mat',resultdir,step),'i1vx');
% 			save(sprintf('%sstep%d_after_local_affine_mvs.mat',resultdir,step),'mvx','mvy','mvz');
% 		end
% 
% 	else
		i1vx = move3dimage(im1,mvy,mvx,mvz);
% 	end
end	
	
abortflag = CheckAbortPauseButtons(mainfigure,0);
if abortflag > 0
	return;	% break out off the loop
end

if models(3) == 1
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle ' - Local Spline Approximation']);
		drawnow;
	end
	if sum(models(1:2)) >= 1
		disp(sprintf('Spline non-rigid approximation for step %d',step));
		[mvy1,mvx1,mvz1] = levelset_motion_free_deform(mainfigure,i1vx,im2,factors(step,3),...
			maxiters(step,3),stops(step,3),spline_smoothing_block_sizes,lowpass_kernal_size,0);
		disp('Computing motion concatenation after spline non-rigid approximation ...');
		disp('Computing motion mvy ...');
		mvy = move3dimage(mvy,mvy1,mvx1,mvz1,'linear') + mvy1;
		disp('Computing motion mvx ...');
		mvx = move3dimage(mvx,mvy1,mvx1,mvz1,'linear') + mvx1;
		disp('Computing motion mvz ...');
		mvz = move3dimage(mvz,mvy1,mvx1,mvz1,'linear') + mvz1;
	else
		disp(sprintf('Spline non-rigid approximation for step %d',step));
		[mvy,mvx,mvz] = levelset_motion_free_deform(mainfigure,im1,im2,factors(step,3),...
			maxiters(step,3),stops(step,3),spline_smoothing_block_sizes,lowpass_kernal_size,0);
	end
	disp('Moving 3D images after spline non-rigid approximation');
% 	if ~isempty(mainfigure)
% 		disp('Updating GUI');
% 		mvyori2 = move3dimage(mvyori,mvy,mvx,mvz,'linear') + mvy;
% 		mvxori2 = move3dimage(mvxori,mvy,mvx,mvz,'linear') + mvx;
% 		mvzori2 = move3dimage(mvzori,mvy,mvx,mvz,'linear') + mvz;
% 		i1vx = move3dimage(im1ori,mvyori2,mvxori2,mvzori2);
% 		UpdateGUI(mainfigure,mvyori2,mvxori2,mvzori2,mvy,mvx,mvz,i1vx);
% 		
% 		if ~exist('resultdir','var') && ~isempty(resultdir)
% 			save(sprintf('%sstep%d_after_spline_i1vx.mat',resultdir,step),'i1vx');
% 			save(sprintf('%sstep%d_after_spline_mvs.mat',resultdir,step),'mvx','mvy','mvz');
% 		end
% 		
% 	else
		i1vx = move3dimage(im1,mvy,mvx,mvz);
% 	end
end

abortflag = CheckAbortPauseButtons(mainfigure,0);
if abortflag > 0
	return;	% break out off the loop
end

if models(4) == 1
	if ~isempty(mainfigure)
		set(mainfigure,'Name',[figureTitle ' - Local free deformation']);
		drawnow;
	end
	if sum(models(1:3)) >= 1
		disp(sprintf('local free deformation for step %d',step));
		[mvy1,mvx1,mvz1] = levelset_motion_free_deform(mainfigure,i1vx,im2,factors(step,3),maxiters(step,4),stops(step,3),[],lowpass_kernal_size);
		disp('Computing motion concatenation after local free deformation ...');
		disp('Computing motion mvy ...');
		mvy = move3dimage(mvy,mvy1,mvx1,mvz1,'linear') + mvy1;
		disp('Computing motion mvx ...');
		mvx = move3dimage(mvx,mvy1,mvx1,mvz1,'linear') + mvx1;
		disp('Computing motion mvz ...');
		mvz = move3dimage(mvz,mvy1,mvx1,mvz1,'linear') + mvz1;
	else
		disp(sprintf('local free deformation for step %d',step));
		[mvy,mvx,mvz] = levelset_motion_free_deform(mainfigure,im1,im2,factors(step,3),maxiters(step,4),stops(step,3),[],lowpass_kernal_size);
	end
	disp('Moving 3D images after local free deformation ...');
% 	if ~isempty(mainfigure)
% % 		disp('Updating GUI');
% % 		mvyori2 = move3dimage(mvyori,mvy,mvx,mvz,'linear') + mvy;
% % 		mvxori2 = move3dimage(mvxori,mvy,mvx,mvz,'linear') + mvx;
% % 		mvzori2 = move3dimage(mvzori,mvy,mvx,mvz,'linear') + mvz;
% 		i1vx = move3dimage(im1ori,mvyori2,mvxori2,mvzori2);
%  		UpdateGUI(mainfigure,mvyori2,mvxori2,mvzori2,mvy,mvx,mvz,i1vx);
% 		
% 		if ~exist('resultdir','var') && ~isempty(resultdir)
% 			save(sprintf('%sstep%d_after_free_deformation_i1vx.mat',resultdir,step),'i1vx');
% 			save(sprintf('%sstep%d_after_free_deformation_mvs.mat',resultdir,step),'mvx','mvy','mvz');
% 		end
% 		
% 	else
		i1vx = move3dimage(im1,mvy,mvx,mvz);
% 	end
end

return;

function UpdateGUI(mainfigure,mvy,mvx,mvz,mvy_res,mvx_res,mvz_res,i1vx)
if( ~isempty(mainfigure) )
	handles = guidata(mainfigure);
	handles.images(1).image_deformed = i1vx;
	handles.reg.dvf.x = mvx;
	handles.reg.dvf.y = mvy;
	handles.reg.dvf.z = mvz;
	handles.reg.mvx_resolution = mvx_res;
	handles.reg.mvy_resolution = mvy_res;
	handles.reg.mvz_resolution = mvz_res;
	handles = configure_sliders(handles);
	guidata(mainfigure,handles);
	
	for k = 1:7
		h = gcf;
		figure(handles.gui_handles.figure1);
		update_display(handles,k);
		figure(h);
	end
	drawnow;
	
	clear handles;
end
return;
