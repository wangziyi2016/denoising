function points_out = deform_contour_points(points, fmvx, fmvy, fmvz, mv_xs, mv_ys, mv_zs)
%
% points_out = deform_contour_points(points, fmvx, fmvy, fmvz, mv_xs, mv_ys, mv_zs)
%
% This function will use the forward DVF to deform contour points
%
% Input:	points		[x0 y0 z0; x1 y1 z1; ... ; xN yN zN] for N points
%			fmvy, fmvx, fmvz			the displacement DVF, the forward DVF
%			mv_xs, mv_ys, mv_zs		the x,y,z value vectors for fmvy, fmvx, fmvz
%

pxs = points(:,1);
pys = points(:,2);
pzs = points(:,3);

outOfBoundsVal = 0;
dxs = interp3(mv_xs, mv_ys, mv_zs, fmvx, pxs, pys, pzs, outOfBoundsVal);
dys = interp3(mv_xs, mv_ys, mv_zs, fmvy, pxs, pys, pzs, outOfBoundsVal);
dzs = interp3(mv_xs, mv_ys, mv_zs, fmvz, pxs, pys, pzs, outOfBoundsVal);

pxs = pxs + dxs;
pys = pys + dys;
pzs = pzs + dzs;

points_out = points;
points_out(:,1) = pxs;
points_out(:,2) = pys;
points_out(:,3) = pzs;



