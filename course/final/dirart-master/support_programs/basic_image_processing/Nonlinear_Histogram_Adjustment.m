function imout = Nonlinear_Histogram_Adjustment(imin,map)
%
% Function: imout = Nonlinear_Histogram_Adjustment(imin,map)
%
% Imin		-	float value between [0,1]
% map		=	user provided map, array of new values between [0, 1]
%			=	1	-	for abdominal CT images
%			=	2	-	for lung
%			=	3	-	for lung and soft tissue
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if isscalar(map)
	switch map
		case 1	% nonlinear adjustment for abdominal CT images
			x = [0  650  800  1000  1050  1200 1300  1500 2000];
			y = [0  0.1  0.2  0.35  0.5   0.6  0.65  0.9  1]*2000;
			map = [x;y]';
		case 2	% for lung
			x = [0  100 200 300 400 500 600 700 800 900 1000];
			y = [0  100 200 300 400 500 600 700 740 770 800];
			map = [x;y]';
		case 3	% for lung  and soft tissue
			x = [0  100 200 300 400 500 600 700 800 900 950  1000 1050 2000];
			y = [0  100 200 300 400 500 600 700 800 900 1100 1300 1500 1600];
			map = [x;y]';
	end
end

classin = class(imin);

dim = size(imin);
imin = single(imin(:));
imin(imin>max(map(:,1))) = max(map(:,1));

imout = interp1(map(:,1),map(:,2),imin);

imout = reshape(imout,dim);

imout = cast(imout,classin);


