function imgout = translate_image(img,resample_resolution,transM,reference_img)
%
% imgout = translate_image(img,resample_resolution);
% imgout = translate_image(img,[],[],reference_img])
%

if nargin < 2
    error('Not enough parameters');
end

if ~exist('transM','var') || isempty(transM)
    if isfield(img,'original_CERR_Scan_Struct') && isfield(img.original_CERR_Scan_Struct,'transM') && ...
            ~isempty(img.original_CERR_Scan_Struct.transM)
        transM = img.original_CERR_Scan_Struct.transM;
        transM(1:3,:) = transM(1:3,:); % mm to cm
        diffM = transM-eye(4);
        if max(abs(diffM(:))) < 1e-4
            % no need to translate
            imgout = img;
            fprintf('No need to translate the image.\n');
            return;
        end
    else
        fprintf('No transM in the image, please provide it.\n');
        imgout = [];
        return;
    end
end

imgout = img;
[ys xs zs] = get_image_XYZ_vectors(img);
if exist('reference_img','var') && ~isempty(reference_img)
    [ysout xsout zsout] = get_image_XYZ_vectors(reference_img);
    imgout.voxelsize = reference_img.voxelsize;
    imgout.voxel_spacing_dir = reference_img.voxel_spacing_dir;
    imgout.origin = reference_img.origin;
else
    % dim = size(img.image);
    [xx yy zz] = meshgrid([xs(1) xs(end)],[ys(1) ys(end)], [zs(1) zs(end)]);
    vecs = [xx(:) yy(:) zz(:) xx(:)-xx(:)+1;xs(2) ys(2) zs(2) 1]';
    vecsout = transM*vecs;
    
    imgout.voxelsize = resample_resolution;
    imgout.voxel_spacing_dir = sign(vecsout([2 1 3],end)-vecsout([2 1 3],1))';
    
    xsout = min(vecsout(1,:)):resample_resolution(2):max(vecsout(1,:));
    if imgout.voxel_spacing_dir(2) == -1
        xsout = fliplr(xsout);
    end
    
    ysout = min(vecsout(2,:)):resample_resolution(1):max(vecsout(2,:));
    if imgout.voxel_spacing_dir(1) == -1
        ysout = fliplr(ysout);
    end
    
    zsout = min(vecsout(3,:)):resample_resolution(3):max(vecsout(3,:));
    if imgout.voxel_spacing_dir(3) == -1
        zsout = fliplr(zsout);
    end
    
    imgout.origin = [ysout(1) xsout(1) zsout(1)];
end

dimout = [length(ysout) length(xsout) length(zsout)];

xsout = single(xsout);
ysout = single(ysout);
zsout = single(zsout);
xs = single(xs);
ys = single(ys);
zs = single(zs);

[xx yy zz] = meshgrid(xsout,ysout,zsout);
vecs = [xx(:) yy(:) zz(:)]';
clear xx yy zz;
transMinv = inv(transM);
vecs2 = transMinv(1:3,1:3)*vecs;
vecs2(1,:) = vecs2(1,:) + transMinv(1,4)*10;
vecs2(2,:) = vecs2(2,:) + transMinv(2,4)*10;
vecs2(3,:) = vecs2(3,:) + transMinv(3,4)*10;
xx = reshape(vecs2(1,:),dimout);
yy = reshape(vecs2(2,:),dimout);
zz = reshape(vecs2(3,:),dimout);

clear vecs vecs2;
imgout.image = interp3wrapper(xs,ys,zs,single(img.image),xx,yy,zz,'linear',nan);
% imgout.image = cast(imgout.image,class(img.image));
% img2 = reshape(img2,dimout);
 

% mask transformation
imgout.structure_mask = [];
imgout.structure_name = [];
imgout.image_deformed = [];






% xs = min(vecs


