function his = joint_hist(im1,im2,bins)
% Function: his = joint_hist(im1,im2,bins)
%
% Calculate the jointed histogram between two images
%
% Input:	im1		-	image 1
%			im2		-	image 2
%				im1 and im2 should be in the same dimension
%			bins	-	number of bins
%
% output:	a [bins x bins] 2D map
%
% By: Deshan Yang, WUSTL, 07/2006
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

im1 = single(im1(:));
im2 = single(im2(:));

maxx = max([im1(:);im2(:)]);

im1 = round(im1 / maxx * (bins-1));
im2 = round(im2 / maxx * (bins-1));

dim = size(im1);
his = zeros(bins);

if ~isempty(find(isnan(im1),1)) && ~isempty(find(isnan(im2),1))
    goodidxes = find((~isnan(im1)) & (~isnan(im2)));
    im1 = im1(goodidxes);
    im2 = im2(goodidxes);
end

for k = 1:prod(size(im1))
	his(im1(k)+1,im2(k)+1) = his(im1(k)+1,im2(k)+1) + 1;
end

his = his / sum(his(:));

