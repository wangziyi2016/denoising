function imgout = ColorRemap(imgin,MAP)
%
%	imgout = ColorRemap(imgin,MAP)
%
N = length(MAP);

dim = size(imgin);
imgin = round(imgin* (N-1)) + 1;
if sum(isnan(imgin(:))) == numel(imgin)
	imgout = MAP(ones(size(imgin)),:);
else
	imgout = MAP(imgin(:),:);
end
imgout = reshape(imgout,dim(1),dim(2),3);
