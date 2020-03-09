function [phi_x,phi_y,abs_grad_phi] = gradient_ENO(phi, accuracy, dx, dy)
%
% function [fx,fy] = gradient_ENO(phi, accuracy, dx, dy)
%
% Calculates the gradient of the 2D data 
%
% dx and dy are the resolution of the grid at x and y dimensions.
% accuracy needs to be specified. Allowed values for accuracy are
% 'ENO1', 'ENO2', 'ENO3', 'WENO'. These correspond to 1st, 2nd, 3rd and 5th order
% accurate schemes for calculating the derivative of phi. 

% Understand what kind of evolution the user is interested in.

if( ~exist('accuracy') )
	accuracy = 'ENO1';
	dx = 1;
	dy = 1;
end

if( ~exist('dx') )
	dx = 1;
end

if( ~exist('dy') )
	dy = 1;
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
data_ext(bwidth+1:end-bwidth,bwidth+1:end-bwidth) = phi;

% Calculate the derivatives (both + and -)
phi_x_minus = zeros(size(phi)+extra);
phi_x_plus = zeros(size(phi)+extra);
phi_y_minus = zeros(size(phi)+extra);
phi_y_plus = zeros(size(phi)+extra);
phi_x = zeros(size(phi)+extra);
phi_y = zeros(size(phi)+extra);

% first scan the rows
for i=1:size(phi,1)
	phi_x_minus(i+bwidth,:) = der_minus(data_ext(i+bwidth,:), dx);	
	phi_x_plus(i+bwidth,:) = der_plus(data_ext(i+bwidth,:), dx);
	
	%phi_x(i+bwidth,:) =  (phi_x_minus(i+bwidth,:) + phi_x_plus(i+bwidth,:))/2;
	phi_x(i+bwidth,:) =  select_der(phi_x_minus(i+bwidth,:),phi_x_plus(i+bwidth,:));
end

% then scan the columns
for j=1:size(phi,2)
	phi_y_minus(:,j+bwidth) = der_minus(data_ext(:,j+bwidth), dy);	
	phi_y_plus(:,j+bwidth) = der_plus(data_ext(:,j+bwidth), dy);	
	%phi_y(:,j+bwidth) = (phi_y_minus(:,j+bwidth)+phi_y_plus(:,j+bwidth))/2;
	phi_y(:,j+bwidth) = select_der(phi_y_minus(:,j+bwidth),phi_y_plus(:,j+bwidth));
end

abs_grad_phi = sqrt(phi_x.^2 + phi_y.^2);

phi_x = phi_x(bwidth+1:end-bwidth,bwidth+1:end-bwidth);
phi_y = phi_y(bwidth+1:end-bwidth,bwidth+1:end-bwidth);
abs_grad_phi = abs_grad_phi(bwidth+1:end-bwidth,bwidth+1:end-bwidth);


return;

