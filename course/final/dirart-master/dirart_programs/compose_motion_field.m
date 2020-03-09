function [mvy,mvx,mvz] = compose_motion_field(mvy1,mvx1,mvz1,mvy2,mvx2,mvz2,dim,offsets)
%
% Composing two pull-back motion fields
%    [mvy,mvx,mvz] = compose_motion_field(mvy1,mvx1,mvz1,mvy2,mvx2,mvz2,dim,offsets)
%    [mvy,mvx,mvz] = compose_motion_field(mvy1,mvx1,mvz1,mvy2,mvx2,mvz2)
%
if ~exist('dim','var') || isempty(dim) || isequal(size(mvy1),size(mvy2))
	mvy = move3dimage(mvy1,mvy2,mvx2,mvz2,'linear') + mvy2;
	mvx = move3dimage(mvx1,mvy2,mvx2,mvz2,'linear') + mvx2;
	mvz = move3dimage(mvz1,mvy2,mvx2,mvz2,'linear') + mvz2;
else
	[mvyL,mvxL,mvzL]=expand_motion_field(mvy1,mvx1,mvz1,dim,offsets);
	mvy = move3dimage(mvyL,mvy2,mvx2,mvz2,'linear',offsets) + mvy2;
	mvx = move3dimage(mvxL,mvy2,mvx2,mvz2,'linear',offsets) + mvx2;
	mvz = move3dimage(mvzL,mvy2,mvx2,mvz2,'linear',offsets) + mvz2;
end

