function [mask2d,ys,xs]=ProjectStructure(handles,strnum,viewdir)
%
%	[mask2d,ys,xs]=ProjectStructure(handles,strnum,viewdir)
%	segments = ProjectStructure(...)
%

[mask3d,yVals,xVals,zVals] = MakeStructureMask(handles.ART.structures{strnum});
% [mask3d,yVals,xVals,zVals] = MakeStructureMask(handles,strnum,2);
mask2d = squeeze(max(mask3d,[],viewdir));

switch viewdir
	case 1
		ys = zVals;
		xs = xVals;
		mask2d = mask2d';
	case 2
		ys = zVals;
		xs = yVals;
		mask2d = mask2d';
	case 3
		ys = yVals;
		xs = xVals;
end

if nargout == 1
	contours = contourd(xs,ys,double(mask2d),[1 1]);
	for k = 1:length(contours)
		points = contours{k};
		segments(k).points = points;
	end
	mask2d = segments;
end
