function [mvy1,mvx1,mvz1] = reg_method_dispatch_inverse_consistency(method,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,iteration_smoothing_setting)
% Redirecting the funtion call according to the deformable registration
% method number
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

% displayflag = ~isempty(mainfigure);

switch method
	case 1	% Horn-Schunck method
		fprintf('Starting Horn-Schunck optical flow method\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('00001',mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,[],[],[],[],[],iteration_smoothing_setting);
	case 2	% LKT method
		fprintf('Starting improved LKT method\n');
		[mvy1,mvx1,mvz1] = optical_flow_lkt_6(3,i1vx,i2vx,voxelsize_ratio,1000,0);
	case 4
		fprintf('Starting Horn-Schunck memory saving\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods_memory_saving(2,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 6	% Combined LKT and global smoothness method
		fprintf('Starting reverse consistency combined LKT and global method\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('01001',mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,[],[],[],[],[],iteration_smoothing_setting);
	case 7	% Combine local LMS and weighted smoothness method
		fprintf('Starting combined local LMS and weighted smoothness optical flow method\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('11001',mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,[],[],[],[],[],iteration_smoothing_setting);
	case 8	% Issam's Non-linear smoothness method
		fprintf('Starting optical flow with Issam non-linear smoothness\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('10001',mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,[],[],[],[],[],iteration_smoothing_setting);
	case 11	% original LKT method
		fprintf('Starting original LKT method\n');
		[mvy1,mvx1,mvz1] = optical_flow_lkt_6(2,i1vx,i2vx,voxelsize_ratio,1000,0);
	case 12 % The original HS + divergence contraint
		fprintf('Starting HS optical flow method with divergence constraint\n');
		[mvy1,mvx1,mvz1] = optical_flow_global_methods('00101',mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop,mvy,mvx,mvz,[],[],iteration_smoothing_setting);
	case 17 % Demon method
		fprintf('Starting demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(11,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 18	% modified demon method
		fprintf('Starting modified demons method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(12,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 19 % SSD Minimization
		fprintf('Starting SSD minimization method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(13,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 20 % Iterative Optical Flow
		fprintf('Starting iterative optical flow method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(14,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 21 % Iterative Levelset Motion
		fprintf('Starting iterative level set method \n');
		[mvy1,mvx1,mvz1] = demon_global_methods(15,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	case 30	% Free form deformation method
		fprintf('Starting reverse consistency fast free form deformation method\n');
		[mvy1,mvx1,mvz1] = fast_free_form_method(2,mainfigure,i1vx,i2vx,voxelsize_ratio,maxiter,stop);
	otherwise
		fprintf('Error: method %d does not support inverse consistency\n',method);
		error(1);
end

