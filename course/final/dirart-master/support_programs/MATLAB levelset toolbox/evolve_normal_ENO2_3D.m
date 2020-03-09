function [delta, H1_abs, H2_abs, H3_abs] = evolve_normal_ENO2_3D(phi, dx, dy, dz, Vn)
%
% Finds the amount of evolution under a force in
% normal direction and using 2nd order accurate ENO scheme
%
% Author: Baris Sumengen  sumengen@ece.ucsb.edu
% http://vision.ece.ucsb.edu/~sumengen/
%

delta = zeros(size(phi)+4);
data_ext = zeros(size(phi)+4);
data_ext(3:end-2,3:end-2,3:end-2) = phi;

% Calculate the derivatives (both + and -)
phi_x_minus = zeros(size(phi)+4);
phi_x_plus = zeros(size(phi)+4);
phi_y_minus = zeros(size(phi)+4);
phi_y_plus = zeros(size(phi)+4);
phi_z_minus = zeros(size(phi)+4);
phi_z_plus = zeros(size(phi)+4);
phi_x = zeros(size(phi)+4);
phi_y = zeros(size(phi)+4);
phi_z = zeros(size(phi)+4);

% first scan the rows
for i=1:size(phi,1)
	for k = 1:size(phi,3)
		phi_x_minus(i+2,:,k+2) = der_ENO2_minus(data_ext(i+2,:,k+2), dx);
		phi_x_plus(i+2,:,k+2) = der_ENO2_plus(data_ext(i+2,:,k+2), dx);
		phi_x(i+2,:,k+2) = select_der_normal(Vn(i+2,:,k+2), phi_x_minus(i+2,:,k+2), phi_x_plus(i+2,:,k+2));
	end
end

% then scan the columns
for j=1:size(phi,2)
	for k=1:size(phi,3)
		phi_y_minus(:,j+2,k+2) = der_ENO2_minus(data_ext(:,j+2,k+2), dy);
		phi_y_plus(:,j+2,k+2) = der_ENO2_plus(data_ext(:,j+2,k+2), dy);
		phi_y(:,j+2,k+2) = select_der_normal(Vn(:,j+2,k+2), phi_y_minus(:,j+2,k+2), phi_y_plus(:,j+2,k+2));
	end
end

% then scan the z
for i=1:size(phi,1)
	for j=1:size(phi,2)
		phi_z_minus(i+2,j+2,:) = der_ENO2_minus(data_ext(i+2,j+2,:), dz);
		phi_z_plus(i+2,j+2,:) = der_ENO2_plus(data_ext(i+2,j+2,:), dz);
		phi_z(i+2,j+2,:) = select_der_normal(Vn(i+2,j+2,:), phi_z_minus(i+2,j+2,:), phi_z_plus(i+2,j+2,:));
	end
end

abs_grad_phi = sqrt(phi_x.^2 + phi_y.^2 + phi_z.^2);

H1_abs = abs(Vn.*phi_x.^2 ./ (abs_grad_phi+dx*dx*(abs_grad_phi == 0)));
H2_abs = abs(Vn.*phi_y.^2 ./ (abs_grad_phi+dx*dx*(abs_grad_phi == 0)));
H3_abs = abs(Vn.*phi_z.^2 ./ (abs_grad_phi+dx*dx*(abs_grad_phi == 0)));
H1_abs = H1_abs(3:end-2,3:end-2,3:end-2);
H2_abs = H2_abs(3:end-2,3:end-2,3:end-2);
H3_abs = H3_abs(3:end-2,3:end-2,3:end-2);

delta = Vn.*abs_grad_phi;
delta = delta(3:end-2,3:end-2,3:end-2);

