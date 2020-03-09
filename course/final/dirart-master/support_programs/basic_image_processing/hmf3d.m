function newimg = hmf3d(img,filtertype)

if( ~exist('filtertype') )
	filtertype = 1;
end

dim = size(img);

for n=1:dim(3)
	switch filtertype
		case 1	% Hybrid median filter
			newimg(:,:,n) = hmf(squeeze(img(:,:,n)));
		case 2	% Regular median filter
			newimg(:,:,n) = medfilt2(squeeze(img(:,:,n)),[5,5]);
		case 3	% Regular median filter
			newimg(:,:,n) = medfilt2(squeeze(img(:,:,n)),[3,3]);
	end
end

