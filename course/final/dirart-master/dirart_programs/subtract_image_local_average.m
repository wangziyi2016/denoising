function imgout = subtract_image_local_average(imgin,window_size)
%
% imgout = subtract_image_local_average(imgin,window_size = 21)
%
%

if ~exist('window_size','var')
    window_size = 21;
end

imgout = single(imgin);
imgout(isnan(imgout)) = 0;
imgout = lowpass3d(imgout,ones(window_size,window_size,window_size)/(window_size^3));
imgout = imgin - imgout;

