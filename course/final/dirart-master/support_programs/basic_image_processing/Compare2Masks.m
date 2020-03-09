function ratio = Compare2Masks(mask,basemask,method)
%
% err=Compare2Masks(mask,basemask,method)
%
% method == 1, compare the entire mask
%		    2, only compare for the slices that basemask is defined
%			3, only compare for the slices that both masks are defined.
%
%
% Output is the ratio:    (M1 and M2) / (M1 + M2)
%

dim = size(mask);

if method == 1
	tempmask = mask+basemask;
elseif method == 2
	tempmask = basemask;
elseif method == 3
	tempmask = mask&basemask;
end

sumz = squeeze(sum(squeeze(sum(tempmask,1)),1));
zs = sumz>0;


% joinmask = mask|basemask;
andmask = mask&basemask;

% joinmask = joinmask(:,:,zs);
mask2 = mask(:,:,zs);
basemask2 = basemask(:,:,zs);
andmask = andmask(:,:,zs);

ratio = single(sum(andmask(:))) / (single(sum(mask2(:)))+single(sum(basemask2(:))));
ratio = ratio*2;


