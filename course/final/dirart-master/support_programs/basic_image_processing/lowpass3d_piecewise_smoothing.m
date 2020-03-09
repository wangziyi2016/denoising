function  im3=lowpass3d_piecewise_smoothing(im,sigma_or_masks,masks)
% Function: im = lowpass3d_piecewise_smoothing(im,sigma_or_masks,masks)
%

if ~exist('masks','var') || max(masks(:)) == 0
	im3=lowpass3d(im,sigma_or_masks);
	return;
end

if ndims(im) == 2
	im3 = lowpass2d(im,sigma_or_masks);
	return;
end

classim = class(im);
im = single(im);
dim=size(im);

mm = 1:dim(1);
nn = 1:dim(2);
kk = 1:dim(3);

N = floor(log2(double(max(masks(:)))))+1;		% number of structures

strnumlow = 0;
if min(masks(:)) > 0 
	strnumlow = 1;
end

masks = uint32(masks);
im3 = zeros(dim,'single');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tic
maxwc1 = 0;
maxwc2 = 0;
maxwc3 = 0;
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
	
	if( ndims(sigma_or_mask) ~= 3 )
		sigma = sigma_or_mask(1);

		w=max(2*sigma,3);

		wc=floor(w/2);
		maxwc1 = max(maxwc1,wc*2+1);
		maxwc2 = max(maxwc2,wc*2+1);
		maxwc3 = max(maxwc3,wc*2+1);
	else
		G = sigma_or_mask;
		dimG = size(G);
		wc1 = floor(dimG(1)/2);
		wc2 = floor(dimG(2)/2);
		wc3 = floor(dimG(3)/2);
		maxwc1 = max(maxwc1,wc1);
		maxwc2 = max(maxwc2,wc2);
		maxwc3 = max(maxwc3,wc3);
	end
end

if numel(im) <= 27
	disp('Computing the narrowband mask ...');
	tempmask = ones([maxwc1 maxwc2 maxwc3]);
	tempmask = tempmask/sum(tempmask(:));
	tempmask = lowpass3d(masks,tempmask);
	tempmask = round(tempmask*10)/10;
	narrowband_mask = (masks ~= tempmask);
	clear tempmask;
end
% toc

% Smoothing for every structure
% tic
% disp('Smoothing for every structures ...');
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
	
	if( ndims(sigma_or_mask) ~= 3 )
		sigma = sigma_or_mask(1);

		w=max(2*sigma,3);

		wc=floor(w/2);
		vec= -wc:wc;
		[x,y,z] = meshgrid(vec,vec,vec);

		v = (x.*x+y.*y+z.*z)/8/sigma;

		G = sigma.^(-0.5)*exp(-v);
		G = G / sum(G(:));
		wc1=wc;wc2=wc;wc3=wc;
	else
		G = sigma_or_mask;
		dimG = size(G);
		wc1 = floor(dimG(1)/2);
		wc2 = floor(dimG(2)/2);
		wc3 = floor(dimG(3)/2);
	end
	
	im2 = zeros(dim,'single');
	if exist('masks','var')
		Gsum = im2;
	end
	
	if strnum > 0
		bitmask = bitget(masks,strnum);
	else
		bitmask = (masks==0);
	end

	% Crop the image according to the structure mask
	
	if numel(im) > 27
		mask_xy = sum(bitmask,3)>0;
		mask_y = sum(mask_xy,2)>0;
		mask_x = sum(mask_xy,1)>0;
		mask_z = squeeze(sum(sum(bitmask,1),2))>0;
		x1 = find(mask_x>0,1,'first');
		x2 = find(mask_x>0,1,'last');
		y1 = find(mask_y>0,1,'first');
		y2 = find(mask_y>0,1,'last');
		z1 = find(mask_z>0,1,'first');
		z2 = find(mask_z>0,1,'last');
		xs = x1:x2;
		ys = y1:y2;
		zs = z1:z2;

		bitmask_b = bitmask(ys,xs,zs);
		im_b = im(ys,xs,zs);
	end
	
	
	% Do convolution
	if numel(im) <= 27
		idxes = find(bitmask==1);
		im3temp = lowpass3d(im,G);
		im3(idxes) = im3temp(idxes); clear im3temp;

		idxes = find(bitmask==1 & narrowband_mask==1);
		for m = -wc1:wc1
			for n = -wc2:wc2
				for k = -wc3:wc3
					mm1 = mm + m; mm1 = max(mm1,1); mm1 = min(mm1,dim(1));
					nn1 = nn + n; nn1 = max(nn1,1); nn1 = min(nn1,dim(2));
					kk1 = kk + k; kk1 = max(kk1,1); kk1 = min(kk1,dim(3));

					bitmask2 = bitmask(mm1,nn1,kk1);
					maskeq = single(bitmask2==bitmask);		% Check if the voxle is the same structure as the center voxel
					im1b = im(mm1,nn1,kk1);

					im2(idxes) = im2(idxes) + im1b(idxes)*G(m+wc+1,n+wc+1,k+wc+1).*maskeq(idxes);
					Gsum(idxes) = Gsum(idxes) + G(m+wc+1,n+wc+1,k+wc+1)*maskeq(idxes);
				end
			end
		end

		im2(idxes) = im2(idxes)./Gsum(idxes);
		im3(idxes) = im2(idxes);
	else
		% Using conv3fft
% 		bitmask_a = conv3fft(single(bitmask),G);
% 		bitmask_a = bitmask_a + (bitmask_a==0);
% 		im2 = conv3fft(im.*single(bitmask),G)./bitmask_a;
% 		im3(bitmask==1) = im2(bitmask==1);
		
		bitmask_a = conv3fft(single(bitmask_b),G);
		bitmask_a = bitmask_a + (bitmask_a==0);
		im2 = conv3fft(im_b.*single(bitmask_b),G)./bitmask_a;
		im2b = im3(ys,xs,zs);
		im2b(bitmask_b==1) = im2(bitmask_b==1);
		im3(ys,xs,zs) = im2b;
	end
end
% toc

im3 = cast(im3,classim);


