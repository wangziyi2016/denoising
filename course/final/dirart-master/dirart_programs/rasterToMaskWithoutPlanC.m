function [dataSet, uniqueSlices] = rasterToMaskWithoutPlanC(rasterSegments, scandim)
%
%	[dataSet, uniqueSlices] = rasterToMaskWithoutPlanC(rasterSegments,scandim)
%
x = scandim(2);
y = scandim(1);

%If no raster segments return empty mask.
if isempty(rasterSegments)
    dataSet = repmat(false, [y,x]);
    uniqueSlices = [];
    return;
end

%Figure out how many unique slices we need.
uniqueSlices = unique(rasterSegments(:, 6));
nUniqueSlices = length(uniqueSlices);
dataSet = repmat(false, [y,x,nUniqueSlices]);

%Loop over raster segments and fill in the proper slice.
for i = 1:size(rasterSegments,1)    
    CTSliceNum = rasterSegments(i,6);
%     index = find(uniqueSlices == CTSliceNum);
    dataSet(rasterSegments(i,7), rasterSegments(i,8):rasterSegments(i,9), uniqueSlices == CTSliceNum) = 1;
end 

