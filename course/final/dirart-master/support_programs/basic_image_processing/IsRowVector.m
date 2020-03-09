function v = IsRowVector(vec)
%
%	v = IsRowVector(vec)
%

if size(vec,2) > 1 && size(vec,1) == 1
	v = 1;
else
	v = 0;
end

