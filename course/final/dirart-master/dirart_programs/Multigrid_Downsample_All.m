function [img1_2,img1_4,img1_8,img2_2,img2_4,img2_8,img2mask_2,img2mask_4,img2mask_8]=Multigrid_Downsample_All(filter,img1,img2,img2mask,levels,displayflag)
%{
[img1_2,img1_4,img1_8,img2_2,img2_4,img2_8,img2mask_2,img2mask_4,img2mask_8]
     =Multigrid_Downsample_All(filter,img1,img2,img2mask,levels)

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

global Gimg1 Gimg2 Gimg2mask Gimg1_2 Gimg1_4 Gimg1_8 Gimg2_2 Gimg2_4 Gimg2_8 Gimg2mask_2 Gimg2mask_4 Gimg2mask_8 Downsample_filter;

switch filter
	case 1	% Gaussian filter
		func = @GPReduce;
		disp('Using GPReduce filter');
	case 2	% Max filter
		func = @MaxReduce;
		disp('Using MaxReduce filter');
	case 3	% Min filter
		func = @MinReduce;
	case 4	% Min/Max filter
		func = @MinMaxReduce;
	case 5	% Mean reduce
		func = @MeanReduce;
end

if isempty(Downsample_filter)
	Downsample_filter = 0;
end

if filter == 1
	check_global_save = 1;
else
	check_global_save = 0;
end

if check_global_save == 0
	disp('Down sampling image #1 for step 2...');
	img1_2 = func(img1,displayflag);

	disp('Down sampling image #2 for step 2...');
	img2_2 = func(img2,displayflag);

	if ~isempty(img2mask)
		img2mask_2 = func(img2mask,displayflag);
	end

	img1_4 = [];
	img2_4 = [];
	img2mask_4 = [];
	if levels > 2
		disp('Down sampling image #1 for step 3...');
		img1_4 = func(img1_2,displayflag);

		disp('Down sampling image #2 for step 3...');
		img2_4 = func(img2_2,displayflag);

		if ~isempty(img2mask)
			disp('Down sampling image #2 mask for step 3...');
			img2mask_4 = func(img2mask_2,displayflag);
		end
	end

	img1_8 = [];
	img2_8 = [];
	img2mask_8 = [];
	if levels > 3
		disp('Down sampling image #1 for step 4...');
		img1_8 = func(img1_4,displayflag);

		disp('Down sampling image #2 for step 4...');
		img2_8 = func(img2_4,displayflag);

		if ~isempty(img2mask)
			disp('Down sampling image #2 mask for step 4...');
			img2mask_8 = func(img2mask_4,displayflag);
		end
	end
else
	if ~isequal(img1,Gimg1) || isempty(Gimg1_2)
		disp('Down sampling image #1 for step 2...');
		Gimg1_2 = func(img1,displayflag);
	end

	if ~isequal(img2,Gimg2) || isempty(Gimg2_2)
		disp('Down sampling image #2 for step 2...');
		Gimg2_2 = func(img2,displayflag);
	end

	if ~isequal(img2mask,Gimg2mask) || isempty(Gimg2mask_2)
		if isempty(img2mask)
			Gimg2mask_2 = [];
		else
			disp('Down sampling image #2 mask for step 2...');
			Gimg2mask_2 = func(img2mask,displayflag);
		end
	end

	if levels > 2
		if ~isequal(img1,Gimg1) || isempty(Gimg1_4)
			disp('Down sampling image #1 for step 3...');
			Gimg1_4 = func(Gimg1_2,displayflag);
		end

		if ~isequal(img2,Gimg2) || isempty(Gimg2_4)
			disp('Down sampling image #2 for step 3...');
			Gimg2_4 = func(Gimg2_2,displayflag);
		end

		if ~isequal(img2mask,Gimg2mask) || isempty(Gimg2mask_4)
			if isempty(img2mask)
				Gimg2mask_4 = [];
			else
				disp('Down sampling image #2 mask for step 3...');
				Gimg2mask_4 = func(Gimg2mask_2,displayflag);
			end
		end
	end

	if levels > 3
		if ~isequal(img1,Gimg1) || isempty(Gimg1_8)
			disp('Down sampling image #1 for step 4...');
			Gimg1_8 = func(Gimg1_4,displayflag);
		end

		if ~isequal(img2,Gimg2) || isempty(Gimg2_8)
			disp('Down sampling image #2 for step 4...');
			Gimg2_8 = func(Gimg2_4,displayflag);
		end

		if ~isequal(img2mask,Gimg2mask) || isempty(Gimg2mask_8)
			if isempty(img2mask)
				Gimg2mask_8 = [];
			else
				disp('Down sampling image #2 mask for step 4...');
				Gimg2mask_8 = func(Gimg2mask_4,displayflag);
			end
		end
	end

	if check_global_save == 1
		Gimg1 = img1;
		Gimg2 = img2;
		Gimg2mask = img2mask;

		img1_2 = Gimg1_2;
		img1_4 = Gimg1_4;
		img1_8 = Gimg1_8;
		img2_2 = Gimg2_2;
		img2_4 = Gimg2_4;
		img2_8 = Gimg2_8;
		img2mask_2 = Gimg2mask_2;
		img2mask_4 = Gimg2mask_4;
		img2mask_8 = Gimg2mask_8;

		Downsample_filter = filter;
	end
end






