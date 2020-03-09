function imgout = half_sample_image(imgin,method, axialonly)
%
% imgout = half_sample_image(imgin,method='mean',axialonly=0)
%
% method = 'gpreduce', 'mean', 'max', 'min', 'median'
%

if ~exist('method','var')
    method = 'mean';
end

if ~exist('axialonly','var')
    axialonly = 0;
end

imgout = imgin;

if axialonly == 0
    switch lower(method)
        case {'gpreduce','gp'}
            imgout.image = GPReduce(imgin.image,1);
        case {'max','maxreduce','max_reduce'}
            imgout.image = MaxReduce(imgin.image,1);
        case {'min','minreduce','min_reduce'}
            imgout.image = MinReduce(imgin.image,1);
        otherwise
            % mean
            imgout.image = MeanReduce(imgin.image,1);
    end
else
    imgout.image = GPReduce2D(imgin.image,1);
    switch lower(method)
        case {'gpreduce','gp'}
            imgout.image = GPReduce2D(imgin.image,1);
        case {'max','maxreduce','max_reduce'}
            imgout.image = MaxReduce2D(imgin.image,1);
        case {'min','minreduce','min_reduce'}
            imgout.image = MinReduce2D(imgin.image,1);
        otherwise
            % mean
            imgout.image = MeanReduce2D(imgin.image,1);
    end
end


if axialonly == 0
	imgout.origin = imgout.origin + imgout.voxelsize .* imgout.voxel_spacing_dir / 2;
	imgout.voxelsize = imgout.voxelsize*2;
else
	imgout.origin(1:2) = imgout.origin(1:2) + imgout.voxelsize(1:2) .* imgout.voxel_spacing_dir(1:2) / 2;
	imgout.voxelsize(1:2) = imgout.voxelsize(1:2)*2;
end

