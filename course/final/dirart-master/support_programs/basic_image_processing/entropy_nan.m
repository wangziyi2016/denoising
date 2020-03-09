function res = entropy_nan(im,mask)
%
% Compute entropy from histogram and taking care of NaN values and log on 0
% values
%
% By: Deshan Yang, 05/2006

if( ~exist('mask') )
	histg = hist(im(:),256);
else
	idx = find(mask==1);
	histg = hist(im(idx),256);
end

histg = histg/sum(histg);

good_idx = find(histg ~= 0);
res = -sum(sum(histg(good_idx).*log2(histg(good_idx))));
