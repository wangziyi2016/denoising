function [f,imout] = intensity_correction(img1)
%
% Image intensity correction for optical flow methods
%
% imout = intensity_correction(imin)
%
% Implemented by: Deshan Yang, 09/2006
%

disp('Performing intensity correction ...');
disp('Computing max img ...');

dim = mysize(img1);

if dim(3) > 1
	maximg1 = minmaxfilt3(img1,'max',9);
else
	maximg1 = maxfilt2(img1,9);
end

disp('Computing min img ...');
if dim(3) > 1
	minimg1 = minmaxfilt3(img1,'min',9);
else
	minimg1 = minfilt2(img1,9);
end

diffimg1 = maximg1 - minimg1;

disp('Performing the correction ...');
f0 = sqrt(diffimg1.^2+0.01);
f = lowpass3d(f0,5);

imout = img1.*f;


