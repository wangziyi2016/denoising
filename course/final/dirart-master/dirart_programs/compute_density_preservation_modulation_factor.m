function factor = compute_density_preservation_modulation_factor(v,u,w,smoothing1,smoothing2)
%
% To compute total density preservation modulation for the image deformation field
% Usage: factor = compute_density_preservation_modulation_factor(vy,vx,vz,smoothing1=0,smoothing2=0);
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%
if ~exist('smoothing1','var') || isempty(smoothing1)
	smoothing1 = 0;
end

if ~exist('smoothing2','var') || isempty(smoothing2)
	smoothing2 = 0;
end


a11 = gradient_1d_by_mask(u,1); clear u;
a22 = gradient_1d_by_mask(v,2); clear v;
a33 = gradient_1d_by_mask(w,3); clear w;

if smoothing1 > 0
	a11 = lowpass3d(a11,smoothing1);
	a22 = lowpass3d(a22,smoothing1);
	a33 = lowpass3d(a33,smoothing1);
end

a11 = a11+1;
a22 = a22+1;
a33 = a33+1;

factor = a11.*a22.*a33;

if smoothing2 > 0
	factor = lowpass3d(factor,smoothing2);
end

factor = 1 ./ (factor + (factor == 0));
