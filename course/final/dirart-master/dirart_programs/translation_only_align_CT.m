function [dy dx dz] = translation_only_align_CT(ct1,ct2,displayflag)
%
% [dy dx dz] = translation_only_align_CT(ct1,ct2)
%
% This function finds the shifting between the two CT images. The two
% images need to be in the same voxel size, but don't have to be in the
% same image dimension.
%
% Image CT1 should be bigger than CT2
%
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('displayflag','var')
	displayflag = 1;
end

dim1 = mysize(ct1);
dim2 = mysize(ct2);

if sum(dim1<dim2) > 0
	fprintf('warning, size of image #2 is bigger.\n');
	dy=0;
	dx=0;
	dz=0;
	return;
end

if displayflag == 1
	fprintf('Aligning center of slices ...\n'); 
end

if isequal(dim1(1:2),dim2(1:2))
	dx = 0;
	dy = 0;
else
	if ndims(ct1) == 2
		slice1 = ct1;
		slice2 = ct2;
	else
		slice1 = ct1(:,:,round(dim1(3)/2));
		slice2 = ct2(:,:,round(dim2(3)/2));
	end
	[x1,y1] = image_centroid(slice1);
	[x2,y2] = image_centroid(slice2);
	dx = round(x1-x2);
	dy = round(y1-y2);
end

if displayflag == 1
	fprintf('Aligning slices ...\n'); 
end

inc(1) = min(ceil((dim1(3)-dim2(3))/5),10);
inc(2) = min(ceil(inc(1)/2),4);
inc(3) = 1;

for pass = 1:3
	if pass == 1
		kb = 0;
		ke = dim1(3)-dim2(3);
	else
		[maxv,idx] = max(MIs);
		ke = min((idx+1)*inc(pass-1)+kb,dim1(3)-dim2(3));
		kb = max((idx-1)*inc(pass-1)+kb,0);
	end
	MIs = [];

	for k = kb:inc(pass):ke
		if displayflag == 1
			fprintf('Compute MI for slice offset = %d (max = %d): ',k,dim1(3)-dim2(3));
		end
		
		yoffs = (1:dim2(1))+dy;
		xoffs = (1:dim2(2))+dx;
		zoffs = (1:dim2(3))+k;

		im1b = ct1(yoffs,xoffs,zoffs);
		MIs(length(MIs)+1) = 1/(images_info(im1b,ct2,'MSE')+0.0001);
		%MIs(length(MIs)+1) = images_info(im1b,handles.images(2).image,'MI');
		if displayflag == 1
			fprintf(' = %g\n',MIs(end));
		end
	end
end

[maxv,idx] = max(MIs);
dz = idx-1+kb;


