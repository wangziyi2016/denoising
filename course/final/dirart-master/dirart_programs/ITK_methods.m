function [mvy,mvx,mvz,i1vx] = ITK_methods(method,im1,im2,ratios,maxiter,offsets)
%{
This is the entry function for all ITK registration methods.

[mvy,mvx,mvz] = ITK_methods(method,im1,im2,ratios,maxiter,offsets=[0 0 0])


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

Hist_Level = 1024;
MatchPoints = 7;
if ~exist('maxiter','var')
	iternum = 200;
else
	iternum = maxiter;
end
sd = 3.0;

if length(ratios) == 1
	spacingF = [1 1 ratios];
	spacingM = [1 1 ratios];
else
	spacingF = ratios;
	spacingM = ratios;
end

originM = [0 0 0];
if exist('offsets','var')
	originF = offsets;
else
	originF = [0 0 0];
end

try
	switch method
		case 1	% ITK demon method
			if ndims(im1) == 2
				[i1vx, mvx, mvy] = Demon(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			else
				[i1vx, mvx, mvy, mvz] = Demons3D(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			end
		case 2	% ITK symmetric demon method
			if ndims(im1) == 2
				[i1vx, mvx, mvy] = SymmetricDemons(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			else
				[i1vx, mvx, mvy, mvz] = SymmetricDemons3D(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			end
		case 3	% ITK Level set method
			sd = 4;
			if ndims(im1) == 2
				[i1vx, mvx, mvy] = levelsetMethod(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			else
				[i1vx, mvx, mvy, mvz] = levelsetMethod3D(int16(im2*10000), originF, spacingF, ...
					int16(im1*10000), originM, spacingM, ...
					Hist_Level, MatchPoints, iternum, sd);
			end
		case 4	% ITK B-spline method
			[i1vx, mvx, mvy, mvz, offset] = BSplineMI(int16(im2*10000), originF, spacingF, ...
				int16(im1*10000), originM, spacingM,0,0,0,0);
		case 5	% ITK fast symmetric demons method
			[i1vx, mvx, mvy, mvz]=SymmetricForcesDemons(int16(im2*10000), originF, spacingF,...
				int16(im1*10000), originM, spacingM,1024,7,0.2,iternum);
	end

	i1vx = single(i1vx)/10000;
	mvx = -mvx / spacingF(2);
	mvy = -mvy / spacingF(1);
	if ndims(im1) == 3
		mvz = -mvz / spacingF(3);
	else
		mvz = mvx*0;
	end
catch
	fprintf('Errors happened in ITK.\n');
end
