function newcoord = Translate1CoordinateValue(handles,baseimgidx,outputimgidx,viewdir,coord)
%
%	newcoord = Translate1CoordinateValue(handles,baseimgidx,outputimgidx,viewdir,coord)
%
%	baseimgidx, outputimgidx: 1 = moving image, 2 = fixed image
%
%
newcoord = coord;
if baseimgidx == outputimgidx
	return;
end

c = handles.reg.images_setting.images_alignment_points;
if baseimgidx == 2
	offs = c(1,:)-c(2,:);
else
	offs = c(2,:)-c(1,:);
end

newcoord = coord + offs(viewdir);
