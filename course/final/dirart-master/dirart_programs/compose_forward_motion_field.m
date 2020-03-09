function [mvy,mvx,mvz] = compose_forward_motion_field(mvy1,mvx1,mvz1,mvy2,mvx2,mvz2)
%
% Composing two pull-back motion fields
%

[mvy,mvx,mvz] = compose_motion_field(mvy2,mvx2,mvz2,mvy1,mvx1,mvz1);

