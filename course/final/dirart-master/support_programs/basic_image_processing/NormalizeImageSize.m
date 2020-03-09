function [M,pre] = NormalizeImageSize(MData, pof2)
%
% [M,pre] = NormalizeImageSize(MData, pof2)
% 

dim = size(MData);
s = 2^pof2;
newdim = floor(dim/s)*s;

trimdim = dim-newdim;
pre = floor(trimdim/2);
post = newdim+pre-1;

M = MData(1+pre(1):1+post(1),1+pre(2):1+post(2),1+pre(3):1+post(3));

 

