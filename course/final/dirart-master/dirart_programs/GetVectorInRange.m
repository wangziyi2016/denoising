function [vecout,idx1,idx2] = GetVectorInRange(vecin,minv,maxv)
%
% [vecout,idx1,idx2] = GetVectorInRange(vecin,minv,maxv)
%

if minv > maxv
	temp = minv;
	minv = maxv;
	maxv = temp;
end

if vecin(2)>vecin(1)
	idx1 = find(vecin<minv,1,'last');
	idx2 = find(vecin>maxv,1,'first');
else
	idx1 = find(vecin>maxv,1,'last');
	idx2 = find(vecin<minv,1,'first');
end

if isempty(idx1)
	idx1 = 1;
end

if isempty(idx2)
	idx2 = length(vecin);
end

vecout = vecin(idx1:idx2);

