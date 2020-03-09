function [mvy,mvx,mvz,i1vx,imvy,imvx,imvz]=multigrid_rc_nogui(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,smoothing_settings,filter_type)
%
% The inverse consistency multi-grid framework, runs without GUI
% Usage:
%	[mvy,mvx,mvz,i1vx,imvy,imvx,imvz]=multigrid_rc_nogui(method,img1,img2,voxelsizes,stagess,maxiters,passesinstages,stop,smoothing_settings,filter_type)
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

% Options
check_motion_vector_magnitude = 1;
% check_motion_vector_magnitude = 0;


% User select image filenames

if( ~exist('voxelsizes','var') || isempty(voxelsizes) )
	voxelsizes = InputImageVoxelSizeRatio();
end
voxelsizes = voxelsizes / min(voxelsizes);

if ~exist('maxiters','var') || isempty(maxiters)
	maxiters = [1 2 3 4 5]*20;
end

if ~exist('passesinstages','var') || isempty(passesinstages)
	passesinstages = [1 2 3 3 3]*2;
end

if ~exist('stop','var') || isempty(stop)
	stop = 2e-3;
end

if ~exist('smoothing_settings','var') || isempty(smoothing_settings)
	smoothing_settings = [3 0 0 0];
end

smoothing_settings = [smoothing_settings 0 0 0];
		

ct0 = cputime;

img2mask = ones(size(img2),'single');


if stagess > 1
	[img1_2,img1_4,img1_8,img2_2,img2_4,img2_8,img2mask_2,img2mask_4,img2mask_8]=Multigrid_Downsample_All(filter_type,img1,img2,img2mask,stagess,0);
	if stagess > 4
		img1_16 = GPReduce(img1_8);
		img2_16 = GPReduce(img2_8);
	end
end

guisecs = 0;	% Time on GUI
calsecs = 0;	% Time on actual computation

ct0=cputime;

abortflag = 0;
for stages = 1:stagess
	real_stages = stagess + 1 - stages;
	ct1 = cputime;
	fprintf('\n\nStarting stages %d\n\n',stages);

	% setting images
	switch real_stages
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

	% Normalize images
	maxv = max(max(im1(:)),max(im2(:)));
	if maxv ~= 1
		im1 = im1/maxv;
		im2 = im2/maxv;
	end
	dim1 = mysize(im1);
	dim2 = mysize(im2);

	% Perform intensity remapping to boost low intensity

	% Initialze motion fields
	ctc = cputime;
	if( stages == 1 )
		fprintf('Initialize motion fields\n');
		mvy = zeros(dim2,'single');
		mvx = zeros(dim2,'single');
		mvz = zeros(dim2,'single');	% mvx, mvy and mvz are the motion vector for each image pixels
		imvy = mvy;
		imvx = mvx;
		imvz = mvz;
		i1vx = im1;
		i2vx = im2;
	else
		fprintf('stages %d - Upscaling the motion field ...\n', stages);
		disp('Upscaling motion field by interpolating ...');
		[mvy,mvx,mvz] = recalculate_mvs(mvy,mvx,mvz,0);
		if ~isequal(size(mvy),dim2)
			mvy = mvy(1:dim2(1),1:dim2(2),1:dim2(3));
			mvx = mvx(1:dim2(1),1:dim2(2),1:dim2(3));
			mvz = mvz(1:dim2(1),1:dim2(2),1:dim2(3));
		end

		disp('Upscaling motion field is finished.');

		disp('Computing moved image by interpolating ...');
		i1vx = move3dimage(im1, mvy/2, mvx/2, mvz/2);

		[imvy,imvx,imvz] = recalculate_mvs(imvy,imvx,imvz,0);
		if ~isequal(size(imvy),dim2)
			imvy = imvy(1:dim2(1),1:dim2(2),1:dim2(3));
			imvx = imvx(1:dim2(1),1:dim2(2),1:dim2(3));
			imvz = imvz(1:dim2(1),1:dim2(2),1:dim2(3));
		end
		%i2vx = move3dimage(im2,-mvy/2,-mvx/2,-mvz/2);
		i2vx = move3dimage(im2,imvy/2,imvx/2,imvz/2);
		disp('Computing moved image is finished');
	end

	calsecs = calsecs + (cputime-ctc);

	ctg = cputime;

	if method == 9	% levelset motion
		passesinstages = [1 1 1 1 1];
	end

	guisecs = guisecs + (cputime-ctg);

	% 	mvx_this_stages = zeros(size(mvx));
	% 	mvy_this_stages = mvx_this_stages;
	% 	mvz_this_stages = mvx_this_stages;

	for pass = 1:passesinstages(real_stages)
		ct2 = cputime;
		fprintf('Computing motion: stages %d - pass %d\n', stages, pass);

		ctc = cputime;
		maxiter = maxiters(real_stages);
		fprintf('With reverse consistency, ');
		switch method
			case 1	% Horn-Schunck method
				fprintf('Starting Horn-Schunck optical flow method\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods('00001',[],i1vx,i2vx,voxelsizes,maxiter,stop,[],[],[],[],[],smoothing_settings(1));
			case 2	% LKT method
				fprintf('Starting improved LKT method\n');
				[mvy1,mvx1,mvz1] = optical_flow_lkt_6(3,i1vx,i2vx,voxelsizes,1000,0);
			case 4
				fprintf('Starting Horn-Schunck memory saving\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods_memory_saving(2,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 6	% Combined LKT and global smoothness method
				fprintf('Starting reverse consistency combined LKT and global method\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods('01001',[],i1vx,i2vx,voxelsizes,maxiter,stop,[],[],[],[],[],smoothing_settings(1));
			case 7	% Combine local LMS and weighted smoothness method
				fprintf('Starting combined local LMS and weighted smoothness optical flow method\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods('11001',[],i1vx,i2vx,voxelsizes,maxiter,stop,[],[],[],[],[],smoothing_settings(1));
			case 8	% Issam's Non-linear smoothness method
				fprintf('Starting optical flow with Issam non-linear smoothness\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods('10001',[],i1vx,i2vx,voxelsizes,maxiter,stop,[],[],[],[],[],smoothing_settings(1));
			case 11	% original LKT method
				fprintf('Starting original LKT method\n');
				[mvy1,mvx1,mvz1] = optical_flow_lkt_6(2,i1vx,i2vx,voxelsizes,1000,0);
			case 12 % The original HS + divergence contraint
				fprintf('Starting HS optical flow method with divergence constraint\n');
				[mvy1,mvx1,mvz1] = optical_flow_global_methods('00101',[],i1vx,i2vx,voxelsizes,maxiter,stop,mvy,mvx,mvz,[],[],smoothing_settings(1));
			case 17 % Demon method
				fprintf('Starting demons method \n');
				[mvy1,mvx1,mvz1] = demon_global_methods(11,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 18	% modified demon method
				fprintf('Starting modified demons method \n');
				[mvy1,mvx1,mvz1] = demon_global_methods(12,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 19 % SSD Minimization
				fprintf('Starting SSD minimization method \n');
				[mvy1,mvx1,mvz1] = demon_global_methods(13,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 20 % Iterative Optical Flow
				fprintf('Starting iterative optical flow method \n');
				[mvy1,mvx1,mvz1] = demon_global_methods(14,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 21 % Iterative Levelset Motion
				fprintf('Starting iterative level set method \n');
				[mvy1,mvx1,mvz1] = demon_global_methods(15,[],i1vx,i2vx,voxelsizes,maxiter,stop);
			case 30	% Free form deformation method
				fprintf('Starting reverse consistency fast free form deformation method\n');
				[mvy1,mvx1,mvz1] = fast_free_form_method(2,[],i1vx,i2vx,voxelsizes,maxiter,stop);
		end
		fprintf('Motion computation stages %d,%d is finished\n',stages,pass);

		if check_motion_vector_magnitude == 1
			if stages < stagess
				[mvx1,mvy1,mvz1]=CheckMagnitude1(mvx1,mvy1,mvz1,maxmotion);
			end

			% 			if stages < stagess
			% 				[mvx1,mvy1,mvz1]=CheckMagnitude2(mvx1,mvy1,mvz1);
			% 			end
		end
		
		if smoothing_settings(2) > 0
			% Extra smoothing
			disp('Extra smoothing the motion fields ...');
			mvy1 = lowpass3d(mvy1,smoothing_settings(2)/real_stages);
			mvx1 = lowpass3d(mvx1,smoothing_settings(2)/real_stages);
			mvz1 = lowpass3d(mvz1,smoothing_settings(2)/real_stages);
		end


		% Save the results
		% Generate the output
		if pass == 1
			mvy_this_stages = mvy1;
			mvx_this_stages = mvx1;
			mvz_this_stages = mvz1;

			imvy_this_stages = -mvy1;
			imvx_this_stages = -mvx1;
			imvz_this_stages = -mvz1;
		else
			disp('Computing result motion field for this pass by interpolating ...');
			mvy_this_stages = move3dimage(mvy_this_stages,mvy1/2,mvx1/2,mvz1/2,'linear') + mvy1;
			mvx_this_stages = move3dimage(mvx_this_stages,mvy1/2,mvx1/2,mvz1/2,'linear') + mvx1;
			mvz_this_stages = move3dimage(mvz_this_stages,mvy1/2,mvx1/2,mvz1/2,'linear') + mvz1;

			imvy_this_stages = move3dimage(imvy_this_stages,-mvy1/2,-mvx1/2,-mvz1/2,'linear') - mvy1;
			imvx_this_stages = move3dimage(imvx_this_stages,-mvy1/2,-mvx1/2,-mvz1/2,'linear') - mvx1;
			imvz_this_stages = move3dimage(imvz_this_stages,-mvy1/2,-mvx1/2,-mvz1/2,'linear') - mvz1;

			% 			mvy_this_stages = mvy_this_stages + mvy1;
			% 			mvx_this_stages = mvx_this_stages + mvx1;
			% 			mvz_this_stages = mvz_this_stages + mvz1;
		end
		
% 		if smoothing_settings(2) > 0
		if smoothing_settings(3) > 0
			% Extra smoothing
			disp('Extra smoothing the motion fields ...');
			mvy_this_stages = lowpass3d(mvy_this_stages,smoothing_settings(2)/real_stages);
			mvx_this_stages = lowpass3d(mvx_this_stages,smoothing_settings(2)/real_stages);
			mvz_this_stages = lowpass3d(mvz_this_stages,smoothing_settings(2)/real_stages);
			imvy_this_stages = lowpass3d(imvy_this_stages,smoothing_settings(2)/real_stages);
			imvx_this_stages = lowpass3d(imvx_this_stages,smoothing_settings(2)/real_stages);
			imvz_this_stages = lowpass3d(imvz_this_stages,smoothing_settings(2)/real_stages);
		end
		

		disp('Computing moved image by interpolating ...');

		i1vx = move3dimage(single(im1), (mvy + mvy_this_stages)/2, (mvx + mvx_this_stages)/2, (mvz + mvz_this_stages)/2,'linear');
		i2vx = move3dimage(single(im2),(imvy + imvy_this_stages)/2,(imvx + imvx_this_stages)/2,(imvz + imvz_this_stages)/2,'linear');
		%i2vx = move3dimage(single(im2),-(mvy + mvy_this_stages)/2,-(mvx + mvx_this_stages)/2,-(mvz + mvz_this_stages)/2,'linear');
		disp('Computing moved image is finished');
		calsecs = calsecs + (cputime-ctc);

		ctg=cputime;
		clear mvx1 mvy1 mvz1;

		i1vx2 = i1vx;
		i2vx2 = i2vx;

		[MI,NMI,MI3,CC,CC2,COV,MSE] = images_info(i1vx2,i2vx2,'MI','NMI','MI3','CC','CC2','cOV','MSE');
		fprintf('stages %d,%d, MI = %d\n',stages, pass, MI);
		fprintf('stages %d,%d, NMI = %d\n',stages, pass, NMI);
		fprintf('stages %d,%d, MI3 = %d\n',stages, pass, MI3);
		fprintf('stages %d,%d, CC = %d\n',stages, pass, CC);
		fprintf('stages %d,%d, CC2 = %d\n',stages, pass, CC2);
		fprintf('stages %d,%d, COV = %d\n',stages, pass, COV);
		fprintf('stages %d,%d, MSE = %d\n',stages, pass, MSE);

		guisecs = guisecs + (cputime-ctg);

		fprintf('This pass used %.2f seconds to finish.\n\n',cputime-ct2);

		abortflag = exist('stop.txt','file');
		if abortflag == 1
			break;	% break out off the pass
		end

		if ~any(method == [1:9 11 12 15 22 23 24]) % Iterative methods do not need multiple passes
			break;	% Don't pass here
		end
	end

% 	if check_motion_vector_magnitude == 1
% 		if stages < 5
% 			[mvx_this_stages,mvy_this_stages,mvz_this_stages]=CheckMagnitude1(mvx_this_stages,mvy_this_stages,mvz_this_stages,maxmotion);
% 		end
% % 		if stages < 4
% % 			[mvx_this_stages,mvy_this_stages,mvz_this_stages]=CheckMagnitude2(mvx_this_stages,mvy_this_stages,mvz_this_stages);
% % 		end
% 	end

	if stages == 1
		mvy = mvy_this_stages;
		mvx = mvx_this_stages;
		mvz = mvz_this_stages;
		imvy = imvy_this_stages;
		imvx = imvx_this_stages;
		imvz = imvz_this_stages;
	else
		disp('Computing result motion field for this stages by interpolating ...');
		mvy = move3dimage(mvy,mvy_this_stages/2,mvx_this_stages/2,mvz_this_stages/2,'linear') + mvy_this_stages;
		mvx = move3dimage(mvx,mvy_this_stages/2,mvx_this_stages/2,mvz_this_stages/2,'linear') + mvx_this_stages;
		mvz = move3dimage(mvz,mvy_this_stages/2,mvx_this_stages/2,mvz_this_stages/2,'linear') + mvz_this_stages;

		imvy = move3dimage(imvy,imvy_this_stages/2,imvx_this_stages/2,imvz_this_stages/2,'linear') + imvy_this_stages;
		imvx = move3dimage(imvx,imvy_this_stages/2,imvx_this_stages/2,imvz_this_stages/2,'linear') + imvx_this_stages;
		imvz = move3dimage(imvz,imvy_this_stages/2,imvx_this_stages/2,imvz_this_stages/2,'linear') + imvz_this_stages;
		% 		mvy = mvy + mvy_this_stages;
		% 		mvx = mvx + mvx_this_stages;
		% 		mvz = mvz + mvz_this_stages;
	end

	if smoothing_settings(4) > 0
% 	if smoothing_settings(2) > 0
		% Extra smoothing
		disp('Extra smoothing the motion fields ...');
		mvy = lowpass3d(mvy,smoothing_settings(2)/real_stages/2);
		mvx = lowpass3d(mvx,smoothing_settings(2)/real_stages/2);
		mvz = lowpass3d(mvz,smoothing_settings(2)/real_stages/2);
		imvy = lowpass3d(imvy,smoothing_settings(2)/real_stages/2);
		imvx = lowpass3d(imvx,smoothing_settings(2)/real_stages/2);
		imvz = lowpass3d(imvz,smoothing_settings(2)/real_stages/2);
	end
	
	clear mvx_this_stages mvy_this_stages mvz_this_stages;

	clear i1vx i2vx;

	fprintf('\nstages %d is finished, used %.2f seconds.\n\n\n',stages,cputime-ct1);

	if abortflag == 1
		disp('Aborted per user request');
		break;	% Break out off the stages
	end
end

% Compute final motion field
disp('Computing final motion field ...');
mvy0 = mvy;
mvx0 = mvx;
mvz0 = mvz;
imvy0 = imvy;
imvx0 = imvx;
imvz0 = imvz;

disp('Inverting motion field 1 ...');
% [imvyt,imvxt,imvzt]=invert_motion_field(imvy0/2,imvx0/2,imvz0/2);
[imvyt,imvxt,imvzt,offsets]= invert_motion_field_smart(imvy0/2,imvx0/2,imvz0/2);
dimmv = size(imvy);
imvyt = imvyt((1:dimmv(1))+offsets(1),(1:dimmv(2))+offsets(2),(1:dimmv(3))+offsets(3));
imvxt = imvxt((1:dimmv(1))+offsets(1),(1:dimmv(2))+offsets(2),(1:dimmv(3))+offsets(3));
imvzt = imvzt((1:dimmv(1))+offsets(1),(1:dimmv(2))+offsets(2),(1:dimmv(3))+offsets(3));


imvyt(isnan(imvyt))=0;
imvxt(isnan(imvxt))=0;
imvzt(isnan(imvzt))=0;

mvy = imvyt + move3dimage(mvy0,imvyt,imvxt,imvzt)/2;
mvx = imvxt + move3dimage(mvx0,imvyt,imvxt,imvzt)/2;
mvz = imvzt + move3dimage(mvz0,imvyt,imvxt,imvzt)/2;

clear imvyt imvxt imvzt;


if nargout > 4
	disp('Inverting motion field 2 ...');

	ci0 = cputime;
	[imvy2,imvx2,imvz2]=invert_motion_field(mvy0/2,mvx0/2,mvz0/2);
	fprintf('Inverting motion field used %.3g seconds\n',cputime-ci0);

	imvy2(isnan(imvy2))=0;
	imvx2(isnan(imvx2))=0;
	imvz2(isnan(imvz2))=0;

	imvy = imvy2 + move3dimage(imvy0,imvy2,imvx2,imvz2)/2;
	imvx = imvx2 + move3dimage(imvx0,imvy2,imvx2,imvz2)/2;
	imvz = imvz2 + move3dimage(imvz0,imvy2,imvx2,imvz2)/2;

	clear imvy2 imvx2 imvz2
end

disp('Compute deformed image 1 ...');
i1vx = move3dimage(single(im1), mvy, mvx, mvz,'linear');

disp('All finished');
fprintf('It took %.2f seconds to finish the entire multigrid registration\n',cputime-ct0);
fprintf('It took %.2f seconds with GUI\n',guisecs);
fprintf('It took %.2f seconds with actually computation\n',calsecs);

diary off;

return;

function [mvx,mvy,mvz]=CheckMagnitude1(mvx,mvy,mvz,thres)
% This stages will restrict the magnitude of the motion field
% in the earlier stagess to be less than threshold. Such a
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
% mvx = lowpass3d(mvx,1);
% mvy = lowpass3d(mvy,1);
% mvz = lowpass3d(mvz,1);


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

