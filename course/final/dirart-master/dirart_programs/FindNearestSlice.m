function [idx,zmatched] = FindNearestSlice(zs,z)
%
%	[idx,zmatched] = FindNearestSlice(zs,z)
%
%	To find the nearest slice, within the slice thickness
%

thickness = max(abs(diff(zs)));
dists = abs(zs-z);
dists(isnan(dists)) = thickness*100;
[distsort,idxes] = sort(dists,'ascend');

zmatched = zs(idxes(1));
if abs(zmatched-z)>thickness
	idx = nan;
else
	idx = idxes(1);
end

