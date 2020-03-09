function imgout = deform_image(imgin,tvf,filter)
%
%	imgout = deform_image(imgin,tvf)
%	imgout = deform_image(imgin,tvf,filter='linear')
%
if ~exist('filter','var')
	filter = 'linear';
end

[imgys,imgxs,imgzs] = get_image_XYZ_vectors(imgin);

imgout = imgin;
imgout = rmfield_from_struct(imgout,{'x','y','z'});
imgout.image = interp3wrapper(imgxs,imgys,imgzs,imgin.image,tvf.x,tvf.y,tvf.z,filter,0);
