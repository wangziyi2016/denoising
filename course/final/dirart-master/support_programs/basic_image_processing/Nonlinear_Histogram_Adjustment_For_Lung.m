function imgout = Nonlinear_Histogram_Adjustment_For_Lung(imgin,maxi,mini,n)
%
% Function: imgout = Nonlinear_Histogram_Adjustment_For_Lung(imgin,maxi=1200,mini=150,n=0.5)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('maxi','var')
	maxi = 1200;
end

if ~exist('mini','var')
	mini = 150;
end

if ~exist('n','var')
	n = 0.5;
end

classname = class(imgin);
imgin = single(imgin);
imgout = min(imgin,maxi);
imgout = max(imgout,mini)-mini;
imgout = (imgout / (maxi-mini)).^n*(maxi-mini);
imgout = cast(imgout,classname);

