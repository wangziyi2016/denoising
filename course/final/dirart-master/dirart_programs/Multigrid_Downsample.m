function varargout=Multigrid_Downsample(img,filter,levels,display)
%{
img_2 =Multigrid_Downsample(img,filter,1,display=0)
[img_2,img_4] =Multigrid_Downsample(img,filter,2,display=0)
[img_2,img_4,img_8] =Multigrid_Downsample(img,filter,3,display=0)
[img_2,img_4,img_8,img_16] =Multigrid_Downsample(img,filter,4,display=0)

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
04/17/2010
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('display','var')
    display = 0;
end

switch filter
	case 1	% Gaussian filter
		func = @GPReduce;
% 		if display>0, disp('Using GPReduce filter'), end;
	case 2	% Max filter
		func = @MaxReduce;
% 		if display>0, disp('Using MaxReduce filter'), end;
	case 3	% Min filter
		func = @MinReduce;
% 		if display>0, disp('Using MinReduce filter'), end;
	case 4	% Min/Max filter
		func = @MinMaxReduce;
% 		if display>0, disp('Using MinMaxReduce filter'), end;
	case 5	% Mean reduce
		func = @MeanReduce;
end
if display>0, fprintf('Using %s filter',func2str(func)), end;

for k = 1:levels
    if display>0, fprintf('Down sampling image by %d ...\n',2^k),end;
    img = func(img,display);
    varargout{k} = img;
end
