function [mvy1,mvx1,mvz1] = reg_method_dispatch(method,mainfigure,i1vx,im2,structure_masks,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,iteration_smoothing_setting)
% Redirecting the funtion call according to the deformable registration
% method number
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

displayflag = ~isempty(mainfigure);

switch method
	case 1	% Horn original global smoothness optical flow method
		fprintf('Starting original Horn-Schunck optical flow method\n');
		if isempty(structure_masks)
			[mvy1,mvx1,mvz1] = optical_flow_global_methods(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,[],iteration_smoothing_setting);
		else
			[mvy1,mvx1,mvz1] = optical_flow_global_methods_piecewise_smoothing(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,structure_masks,iteration_smoothing_setting);
		end
	case 2	% Lucas and Kanade's local LMS method
		fprintf('Starting improved LKT optical flow method\n');
		[mvy1,mvx1,mvz1] = optical_flow_lkt_6(1,i1vx,im2,voxelsizes,1000,0,image_current_offsets,displayflag);
	case 3	% Horn original global smoothness optical flow method - integer approach
		fprintf('Starting HS optical flow method with global smoothness\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods_integer(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,[],[],[],image_current_offsets);
	case 4	% Horn original global smoothness optical flow method - memory saving
		fprintf('Starting HS optical flow method, memory saving\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods_memory_saving(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,image_current_offsets);
	case 6	% Combine local LMS and global smoothness method
		fprintf('Starting combined local LMS and global smoothness optical flow method\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods(3,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,[],iteration_smoothing_setting);
	case 7	% Combine local LMS and weighted smoothness method
		fprintf('Starting combined local LMS and weighted smoothness optical flow method\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods(4,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,[],iteration_smoothing_setting);
	case 8	% Issam's Non-linear smoothness method
		fprintf('Starting optical flow with Issam non-linear smoothness\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods(2,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,[],iteration_smoothing_setting);
	case 9	% Levelset motion method
		%[mvy1,mvx1,mvz1] = levelset_motion_free_deform_wo_gui(i1vx,im2,lmfactors(real_step),lmmaxiters(real_step),lmtors(real_step),[],[3 3 3],2,1);
		%[mvy1,mvx1,mvz1] = levelset_motion_0(i1vx,im2,lmfactors(real_step),lmmaxiters(real_step),lmtors(real_step));
		%[mvy1,mvx1,mvz1] = levelset_motion_wo_gui(i1vx,im2,voxelsizes,step,mainfigure,im1,mvy,mvx,mvz,resultdir);
		fprintf('Starting improved level set method\n');
% 		[mvy1,mvx1,mvz1] = levelset_motion_wo_gui(i1vx,im2,voxelsizes,2,mainfigure,im1,mvy,mvx,mvz);
        [mvy1,mvx1,mvz1] = levelset_motion_wo_gui(i1vx,im2,voxelsizes,2,mainfigure);%,im1,mvy,mvx,mvz);
	case 10 % Affine approximation of motion field
		fprintf('Starting level set method with affine approximation\n');
		[mvy1,mvx1,mvz1] = optical_flow_affine(i1vx,im2);
	case 11 % The original LKT LMS method
		fprintf('Starting original LKT optical flow method\n');
		%[mvy1,mvx1,mvz1] = optical_flow_lkt_0(i1vx,im2,voxelsizes);
		[mvy1,mvx1,mvz1] = optical_flow_lkt_6(0,i1vx,im2,voxelsizes);
	case 12 % The original HS + divergence contraint
		fprintf('Starting HS optical flow method with divergence constraint\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('001',mainfigure,i1vx,im2,voxelsizes,maxiter,stop,mvy,mvx,mvz,image_current_offsets,[],iteration_smoothing_setting);
	case 15 % Inverse consistency Horn-Schunck
		fprintf('Starting HS optical flow method, reverse consistency B\n');
		[mvy1,mvx1,mvz1] = optical_flow_inverse_consistency_methods(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop);
	case 17 % Demon method
		fprintf('Starting demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets,mvy,mvx,mvz);
	case 18	% modified demon method
		fprintf('Starting modified demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(2,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets,mvy,mvx,mvz);
	case 19 % SSD Minimization
		fprintf('Starting SSD minimization method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(3,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets,mvy,mvx,mvz);
	case 20 % Iterative Optical Flow
		fprintf('Starting iterative optical flow method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(4,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets,mvy,mvx,mvz);
	case 21 % Iterative Levelset Motion
		fprintf('Starting iterative level set method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(5,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets,mvy,mvx,mvz);
	case 22 % Fast demon method
		fprintf('Starting fast demons method \n');
		[mvy1,mvx1,mvz1] = fast_demon_global_methods(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets);
	case 23 % Fast iterative optical flow
		fprintf('Starting fast iterative optical flow method \n');
		[mvy1,mvx1,mvz1] = fast_demon_global_methods(2,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets);
	case 24 % Fast demon method with elastic regularization constraint
		fprintf('Starting fast demons method with elastic regularization constraint\n');
		[mvy1,mvx1,mvz1] = fast_demon_global_methods(3,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,iteration_smoothing_setting,image_current_offsets);
	case 25	% ITK Demon method
		fprintf('Starting ITK demons method\n');
		[mvy1,mvx1,mvz1] = ITK_methods(1,i1vx,im2,voxelsizes,maxiter,image_current_offsets);
	case 26	% ITK symetric Demons method
		fprintf('Starting ITK symmetric demons method\n');
		[mvy1,mvx1,mvz1] = ITK_methods(2,i1vx,im2,voxelsizes,maxiter,image_current_offsets);
	case 27	% ITK Levelset method
		fprintf('Starting ITK level set method\n');
		[mvy1,mvx1,mvz1] = ITK_methods(3,i1vx,im2,voxelsizes,maxiter,image_current_offsets);
	case 28	% Original levelset method
		lmfactors = [1 1 1 1 1];
		lmmaxiters = [20 40 60 80 100];
		fprintf('Starting original level set method\n');
		[mvy1,mvx1,mvz1] = levelset_motion_0(mainfigure,i1vx,im2,1,maxiter,stop);
	case 29	% ITK Bspline method
		fprintf('Starting ITK Bspline method\n');
		[mvy1,mvx1,mvz1] = ITK_methods(4,i1vx,im2,voxelsizes,maxiter,image_current_offsets);
	case 30 % Fast free form deformation method by Weiguo Lu
		fprintf('Starting Lu''s fast free form deformation method\n');
		[mvy1,mvx1,mvz1] = fast_free_form_method(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,image_current_offsets,mvy,mvx,mvz);
	case 31 % Symmetric Force Demon method
		fprintf('Starting demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(6,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,[],image_current_offsets);
	case 32 % Symmetric Force Demon method
		fprintf('Starting demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(7,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,[],image_current_offsets);
	case 33 % ITK Fast Symmetric Demon method
		fprintf('Starting demons method \n');
		[mvy1,mvx1,mvz1] = ITK_methods(5,i1vx,im2,voxelsizes,maxiter,image_current_offsets);
	otherwise	% Otherwise, use original optical flow method
		warning(sprintf('Registration method %d is not available.',method));
		[mvy1,mvx1,mvz1] = optical_flow_global_methods(1,mainfigure,i1vx,im2,voxelsizes,maxiter,stop,[],[],[],image_current_offsets,[],iteration_smoothing_setting);
end

return;

