function idx = GetIndexFromCoordinate(vec,coord)
%
%
%
dist = abs(vec-coord);
[v,idx] = min(dist);

