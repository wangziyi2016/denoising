function fmap = intensity_correction_factor_map(imin,neighborsize,sigma)
%
% fmap = intensity_correction_factor_map(imin,neighborsize,sigma)
%

%disp('Performing intensity correction ...');
%disp('Computing max img ...');
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = mysize(imin);

if dim(3) > 1
	maximg1 = minmaxfilt3(imin,'max',neighborsize);
else
	maximg1 = maxfilt2(imin,neighborsize);
end

%disp('Computing min img ...');
if dim(3) > 1
	minimg1 = minmaxfilt3(imin,'min',neighborsize);
else
	minimg1 = minfilt2(imin,neighborsize);
end

diffimg1 = maximg1 - minimg1;

%disp('Performing the correction ...');
fmap = 1./sqrt(diffimg1.^2+0.01);
fmap = lowpass3d(fmap,sigma);
