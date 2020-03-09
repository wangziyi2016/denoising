function handles = Align_Images_After_Loading(handles)
%
%	handles = Align_Images_After_Loading(handles)
%

% lists{1} = CreateStructureList(handles.images(1));
% lists{2} = CreateStructureList(handles.images(2));
lists{1} = CreateStructureList(handles,1);
lists{2} = CreateStructureList(handles,2);
h1 = ImageAlignmentUI(lists);
uiwait;
if ~ishandle(h1)
	% the window is closed / cancelled
	return;
end

hh = guidata(h1);
selections(1) = get(hh.listbox1,'value');
selections(2) = get(hh.listbox2,'value');
close(h1);

if hh.cancel == 1
	% the window is closed / cancelled
	return;
end

refresh;

for k = 1:2
	if selections(k) == 1
		[ys,xs,zs] = get_image_XYZ_vectors(handles.images(k));
		% use the center of the image
		c(k,1) = (ys(1)+ys(end))/2;
		c(k,2) = (xs(1)+xs(end))/2;
		c(k,3) = (zs(1)+zs(end))/2;
	else
		% use the center of the structure (k-1) 
		strnum = str2double(lists{k}{selections(k)}(1:3));
		if handles.ART.structures{strnum}.meshRep ==0
			c(k,:) = ComputeStructureCenterPos(handles,strnum);
		else
			[mask,ys,xs,zs] = MakeStructureMask(handles,strnum,2);
			c(k,:) = ComputeStructureCenterPos(single(mask),ys,xs,zs);
			clear mask;
		end
	end
end

% handles.reg.images_setting.image_offsets = round((size(handles.images(1).image)-size(handles.images(2).image))/2);	% Align the images in the center
handles.reg.images_setting.image_coordinate_offsets = c(1,:)-c(2,:);	% not used anymore
handles.reg.images_setting.images_alignment_points = c;

ori1 = (handles.images(1).origin - c(1,:)).*handles.images(1).voxel_spacing_dir;
ori2 = (handles.images(2).origin - c(2,:)).*handles.images(2).voxel_spacing_dir;
handles.reg.images_setting.image_offsets = round((ori2-ori1)./handles.images(1).voxelsize);
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
handles = RecoverImageAlignmentPoints(handles);
return


function strs = CreateStructureList(handles,imgidx)
strs{1} = 'The whole Image';
if ~isempty(handles.ART.structures)
	N = length(handles.ART.structures);
	for strnum = 1:N
		if handles.ART.structure_assocImgIdxes(strnum) == imgidx
			strs{1+end} = sprintf('%d  - %s',strnum,handles.ART.structure_names{strnum});
		end
	end
end
return;
