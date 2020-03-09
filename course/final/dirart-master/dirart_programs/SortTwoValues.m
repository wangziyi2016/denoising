function [v1,v2]=SortTwoValues(v1,v2,mode)
if ~exist('mode','var')
	mode = 'ascend';
end

if mode == 1
	% ascend
	v = sort([v1 v2],mode);
else
	% descend
	v = sort([v1 v2],mode);
end

v1 = v(1);
v2 = v(2);

