function offs = GetCoordinateOffsets(handles,baseimgidx,outputimgidx)
%
%	offs = GetCoordinateOffsets(handles,baseimgidx,outputimgidx)
%
if baseimgidx ~= outputimgidx
	c = handles.reg.images_setting.images_alignment_points;
	if baseimgidx == 2
		offs = c(1,:)-c(2,:);
	else
		offs = c(2,:)-c(1,:);
	end
else
	offs= [0 0 0];
end
