function [slicec,slice] = Get_Image_Slice(img3d,viewdir,dimc,offsets_c,sliceno,max_projection)
%
%	[slicec,slice] = Get_Image_Slice(img3d,viewdir,dimc,offsets_c,sliceno,max_projection)
%
if ~exist('max_projection','var')
	max_projection = 0;
end

dim = mysize(img3d);
if length(sliceno) == 1
	sliceno_actual = sliceno - offsets_c(viewdir);
else
	sliceno_actual = sliceno(viewdir) - offsets_c(viewdir);
end

max_projection_slice_interval = 10;
max_projection_num_slices = 20;

if max_projection == 1
	interval = round(dim(viewdir)/max_projection_num_slices);
	interval = max(interval,max_projection_slice_interval);
	switch viewdir
		case 1
			img3d2 = img3d(1:interval:end,:,:);
		case 2
			img3d2 = img3d(:,1:interval:end,:);
		case 3
			img3d2 = img3d(:,:,1:interval:end);
	end
	slice = squeeze(max(img3d2,[],viewdir));
elseif max_projection == 2 && isinteger(img3d)
	slice = bitOpn(img3d,viewdir,'or');
end

switch viewdir
	case 1
		if isinteger(img3d)
			slicec = zeros(dimc(2),dimc(3),class(img3d));
		else
			slicec = nan(dimc(2),dimc(3));
		end
		if max_projection >= 1
			slicec(offsets_c(2)+(1:dim(2)),offsets_c(3)+(1:dim(3))) = slice;
		else
			if sliceno_actual >= 1 && sliceno_actual <= dim(1)
				slice = squeeze(img3d(sliceno_actual,:,:));
				slicec(offsets_c(2)+(1:dim(2)),offsets_c(3)+(1:dim(3))) = slice;
			else
				slice = nan(dim(2),dim(3));
			end
		end
	case 2
		if isinteger(img3d)
			slicec = zeros(dimc(1),dimc(3),class(img3d));
		else
			slicec = nan(dimc(1),dimc(3));
		end
		if max_projection >= 1
			slicec(offsets_c(1)+(1:dim(1)),offsets_c(3)+(1:dim(3))) = slice;
		else
			if sliceno_actual >= 1 && sliceno_actual <= dim(2)
				slice = squeeze(img3d(:,sliceno_actual,:));
				slicec(offsets_c(1)+(1:dim(1)),offsets_c(3)+(1:dim(3))) = slice;
			else
				slice = nan(dim(1),dim(3));
			end
		end
	case 3
		if isinteger(img3d)
			slicec = zeros(dimc(1),dimc(2),class(img3d));
		else
			slicec = nan(dimc(1),dimc(2));
		end
		if max_projection >= 1
			slicec(offsets_c(1)+(1:dim(1)),offsets_c(2)+(1:dim(2))) = slice;
		else
			if sliceno_actual >= 1 && sliceno_actual <= dim(3)
				slice = squeeze(img3d(:,:,sliceno_actual));
				slicec(offsets_c(1)+(1:dim(1)),offsets_c(2)+(1:dim(2))) = slice;
			else
				slice = nan(dim(1),dim(2));
			end
		end
end
return;
