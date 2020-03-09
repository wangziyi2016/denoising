function [phi_x,phi_y,phi_z,abs_grad_phi] = gradient_ENO_3d(phi, accuracy, dx, dy,dz)
%
% function [fx,fy,fz] = gradient_ENO_3d(phi, accuracy, dx, dy, dz)
%
% Calculates the gradient of the 3D data 
%
% dx,dy and dz are the resolution of the grid at x, y and z dimensions.
% accuracy needs to be specified. Allowed values for accuracy are
% 'ENO1', 'ENO2', 'ENO3', 'WENO'. These correspond to 1st, 2nd, 3rd and 5th order
% accurate schemes for calculating the derivative of phi. 

% Understand what kind of evolution the user is interested in.

if( ~exist('accuracy','var') )
	accuracy = 'ENO1';
	dx = 1;
	dy = 1;
	dz = 1;
end

if( ~exist('dx','var') )
	dx = 1;
end

if( ~exist('dy','var') )
	dy = 1;
end

if( ~exist('dz','var') )
	dz = 1;
end

switch(accuracy)
	case 'ENO1'
		der_minus = @der_ENO1_minus;
		der_plus = @der_ENO1_plus;
		extra = 2;
	case 'ENO2'
		der_minus = @der_ENO2_minus;
		der_plus = @der_ENO2_plus;
		extra = 4;
	case 'ENO3'
		der_minus = @der_ENO3_minus;
		der_plus = @der_ENO3_plus;
		extra = 6;
	case 'WENO'
		der_minus = @der_WENO_minus;
		der_plus = @der_WENO_plus;
		extra = 6;
	otherwise
		error('Desired type of the accuracy is not correctly specified!');
end

bwidth = extra/2;	% Boundary width

delta = zeros(size(phi)+extra);
data_ext = zeros(size(phi)+extra);
data_ext(bwidth+1:end-bwidth,bwidth+1:end-bwidth,bwidth+1:end-bwidth) = phi;

% Calculate the derivatives (both + and -)

% first scan the rows
phi_x_minus = zeros(size(phi)+extra);
phi_x_plus = zeros(size(phi)+extra);
phi_x = zeros(size(phi)+extra);
for i=1:size(phi,1)
	for j=1:size(phi,3)
		phi_x_minus(i+bwidth,:,j+bwidth) = der_minus(data_ext(i+bwidth,:,j+bwidth), dx);
		phi_x_plus(i+bwidth,:,j+bwidth) = der_plus(data_ext(i+bwidth,:,j+bwidth), dx);
		phi_x(i+bwidth,:,j+bwidth) =  select_der(phi_x_minus(i+bwidth,:,j+bwidth),phi_x_plus(i+bwidth,:,j+bwidth));
	end
end

clear phi_x_minus phi_x_plus;

% then scan the columns
phi_y_minus = zeros(size(phi)+extra);
phi_y_plus = zeros(size(phi)+extra);
phi_y = zeros(size(phi)+extra);
for i=1:size(phi,2)
	for j=1:size(phi,3)
		phi_y_minus(:,i+bwidth,j+bwidth) = der_minus(data_ext(:,i+bwidth,j+bwidth), dy);
		phi_y_plus(:,i+bwidth,j+bwidth) = der_plus(data_ext(:,i+bwidth,j+bwidth), dy);
		phi_y(:,i+bwidth,j+bwidth) = select_der(phi_y_minus(:,i+bwidth,j+bwidth),phi_y_plus(:,i+bwidth,j+bwidth));
	end
end

clear phi_y_minus phi_y_plus;

% then scan z direction
phi_z_minus = zeros(size(phi)+extra);
phi_z_plus = zeros(size(phi)+extra);
phi_z = zeros(size(phi)+extra);
for i=1:size(phi,1)
	for j=1:size(phi,2)
		phi_z_minus(i+bwidth,j+bwidth,:) = der_minus(data_ext(i+bwidth,j+bwidth,:), dz);
		phi_z_plus(i+bwidth,j+bwidth,:) = der_plus(data_ext(i+bwidth,j+bwidth,:), dz);
		phi_z(i+bwidth,j+bwidth,:) = select_der(phi_z_minus(i+bwidth,j+bwidth,:),phi_z_plus(i+bwidth,j+bwidth,:));
	end
end

clear phi_z_minus phi_z_plus;


abs_grad_phi = sqrt(phi_x.^2 + phi_y.^2 + phi_z.^2);

% The final results
phi_x = phi_x(bwidth+1:end-bwidth,bwidth+1:end-bwidth,bwidth+1:end-bwidth);
phi_y = phi_y(bwidth+1:end-bwidth,bwidth+1:end-bwidth,bwidth+1:end-bwidth);
phi_z = phi_z(bwidth+1:end-bwidth,bwidth+1:end-bwidth,bwidth+1:end-bwidth);
abs_grad_phi = abs_grad_phi(bwidth+1:end-bwidth,bwidth+1:end-bwidth,bwidth+1:end-bwidth);


return;

