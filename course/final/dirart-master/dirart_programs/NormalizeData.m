function dataout = NormalizeData(datain,minv,maxv)
%
%	dataout = NormalizeData(datain,minv,maxv)
%	Normalizing the datain to [0 1]
%
if ~exist('maxv','var')
	maxv = max(datain(:));
end
if ~exist('minv','var')
	minv = min(datain(:));
end

datain = datain-minv;
maxv = maxv - minv;

dataout = datain / maxv;
dataout = max(dataout,0);
dataout = min(dataout,1);


