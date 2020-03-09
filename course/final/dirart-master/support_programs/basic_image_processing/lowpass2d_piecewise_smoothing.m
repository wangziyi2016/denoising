function  im3=lowpass2d_piecewise_smoothing(im,sigma_or_masks,masks)
% Function: im = lowpass2d_piecewise_smoothing(im,sigma_or_masks,masks)
%
% if sigma_or_masks is scalar values, they will be used a the sigma values for
% the Gaussian smoothly masks for each structure. Or it must be a cell array of 3D arrays to be used as the 3D
% smoothly masks, and the dimensions must be odd.
%
%
%

if ~exist('masks','var') || max(masks(:)) == 0
	im3=lowpass2d(im,sigma_or_masks);
	return;
end

classim = class(im);
im = single(im);

dim=size(im);
mm = 1:dim(1);
nn = 1:dim(2);

N = floor(log2(max(masks)))+1;		% number of structures

strnumlow = 0;
if min(masks(:)) > 0 
	strnumlow = 1;
end

masks = uint32(masks);
im3 = zeros(dim,'single');

for strnum = strnumlow:N	% N structures + voxels not belong to any structures
	masknum = strnum;
	if strnum == 0
		masknum = N+1;
	end
	if masknum > length(sigma_or_masks)
		masknum = 1;
	end
	
	
	if iscell(sigma_or_masks)
		sigma_or_mask = sigma_or_masks{masknum};
	else
		sigma_or_mask = sigma_or_masks(masknum);
	end
	
	if( min(size(sigma_or_mask)) == 1 )
		sigma = sigma_or_mask(1);
		w=max(2*sigma,3);

		wc=floor(w/2);
		wc1 = wc;
		wc2 = wc;
		vec = -wc:wc;
		[x,y] = meshgrid(vec,vec);

		G = sigma.^(-0.5)*exp(-(x.*x+y.*y)/4/sigma);
		G = G / sum(G(:));
	else
		G = sigma_or_mask;
		if ndims(G) == 3
			G = squeeze(G(:,:,1));
			G = G / sum(G(:));
		end
		wc1 = (size(G,1)-1)/2;
		wc2 = (size(G,2)-1)/2;
	end


	% Do convolution
	
	im2 = zeros(dim,'single');
	if exist('masks','var')
		Gsum = im2;
	end
	
	if strnum > 0
		bitmask = bitget(masks,strnum);
	else
		bitmask = masks==0;
	end

	idxes = find(bitmask==1);
	for m = wc1:wc2
		for n = wc1:wc2
			mm1 = mm + m; mm1 = max(mm1,1); mm1 = min(mm1,dim(1));
			nn1 = nn + n; nn1 = max(nn1,1); nn1 = min(nn1,dim(2));
			bitmask2 = bitmask(mm1,nn1);
			maskeq = single(bitmask2==bitmask);		% Check if the voxle is the same structure as the center voxel
			im1b = im(mm1,nn1);
			
			im2(idxes) = im2(idxes) + im1b(idxes)*G(m-wc1+1,n-wc1+1).*maskeq(idxes);
			Gsum(idxes) = Gsum(idxes) + G(m-wc1+1,n-wc1+1)*maskeq(idxes);
% 			im2 = im2 + im(mm1,nn1)*G(m-wc1+1,n-wc1+1).*maskeq;		% Averaging only with voxels of the same structure
% 			Gsum = Gsum + G(m-wc1+1,n-wc1+1)*maskeq;
		end
	end

	im2(idxes) = im2(idxes)./Gsum(idxes);
	im3(idxes) = im2(idxes);
end

im3 = cast(im3,classim);



