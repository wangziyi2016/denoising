function [xs,ys,zs]=TranslateCoordinates(handles,direction,xs,ys,zs,img)
%
%	[xs,ys,zs]=TranslateCoordinates(handles,direction,xs,ys,zs)
%	[xs,ys,zs]=TranslateCoordinates(handles,imgidx,xs,ys,zs)
%	[xs,ys,zs]=TranslateCoordinates(handles,direction,xs,ys,zs,img)
%
%	Direction = 1:	From the moving image to the fixed image
%				2:	From the fixed image to the moving image
%
if ~exist('img','var')
	img = handles.images(direction);
end

% Are the coordinate increasing directions the same?
samedir = handles.images(3-direction).voxel_spacing_dir .* img.voxel_spacing_dir;

% Convert to relative coordinate
c = handles.reg.images_setting.images_alignment_points;
ys = ys - c(direction,1);
xs = xs - c(direction,2);
zs = zs - c(direction,3);

ys = ys * samedir(1);
xs = xs * samedir(2);
zs = zs * samedir(3);


ys = ys + c(3-direction,1);
xs = xs + c(3-direction,2);
zs = zs + c(3-direction,3);

xs = double(xs);
ys = double(ys);
zs = double(zs);
