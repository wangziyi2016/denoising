function imgout = preprocess_MVCT_image(imgin,ask)
% imgout = Processing_MVCT_image(imgin,ask=1)
% will denoise the MVCT image, and mark voxels outside FOV as nan

dim = mysize(imgin);

if dim(1) ~= 512 || dim(2) ~= 512
	% MVCT should be 512x512 by default
	disp('MVCT images are not processed because the dimension is not 512x512, check me pls');
	imgout = imgin;
	return;
end

if ~exist('ask','var')
	ask = 1;
end

if ask ~= 1
	denoise = 1;
	marknan = 1;
end

if ask == 1
	answer=questdlg('Denoising MVCT images?', 'Denoising MVCT images?','Yes','No','Yes');
	if strcmp(answer,'Yes')
		denoise = 1;
	else
		denoise = 0;
	end
end

if denoise == 1
	fprintf('Denoising MVCT images, totally %d slices ...\n',dim(3));
	drawnow;
	imgout = denoise3in2(13,imgin);
% 	sigma = 3;
% 	imgout = bfilter3in2(imgin,sigma,[sigma 0.1]);
	disp('Denoising MVCT images is finished');
else
	imgout = imgin;
end

if ask == 1
	answer=questdlg('Marking voxels outside FOV as NaN?', 'Mark NaN?','Yes','No','Yes');
	if strcmp(answer,'Yes')
		marknan = 1;
	else
		marknan = 0;
	end
end

if marknan == 1
	mask = create_MVCT_FOV_mask;
	for k = 1:dim(3)
		slice = imgout(:,:,k);
		slice(mask==0) = nan;
		imgout(:,:,k) = slice;
	end
end



