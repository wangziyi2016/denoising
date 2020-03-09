function [rx,ry] = ComputeAxesLimitToPositionRatio(hAxes)
%
%
%
a = get(hAxes);
b = get(a.Parent,'Position');
posa = a.Position.*[b(3:4) b(3:4)];	% In pixels

%X,Y limits are always manually set
if strcmpi(a.DataAspectRatioMode,'auto') == 0
	% The axis area is not filled
	datarange = [diff(a.XLim)+1 diff(a.YLim)+1];
	rr = posa(3:4) ./ datarange .* a.DataAspectRatio(1:2);	
	r = min(rr) ./ a.DataAspectRatio(1:2);	% Data range to pixel ratio
else
	% The axis area is filled
	datarange = [diff(a.XLim)+1 diff(a.YLim)+1];
	r = posa(3:4) ./ datarange;	
end

rx = r(1);
ry = r(2);
