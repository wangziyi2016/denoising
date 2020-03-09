function [cx,cy] = image_centroid(im)
%
% [cx,cy] = image_centroid(im)
%
  
im = single(im);
im(isnan(im)) = 0;

dim = size(im);
[x,y]=meshgrid(1:dim(2),1:dim(1));
im = im(:);
x = x(:);
y = y(:);
weight = sum(im);
cx = sum(im.*x)/weight;
cy = sum(im.*y)/weight;
