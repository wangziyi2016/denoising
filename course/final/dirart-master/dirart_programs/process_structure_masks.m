function masksout = process_structure_masks(masks,action,varargin)
%
% masksout = process_structure_masks(masksin,'smoothing',kernelsize)
% masksout = process_structure_masks(masksin,'expanding',kernelsize)
% masksout = process_structure_masks(masksin,'shrinking',kernelsize)
%

kernelsize = varargin{1};

if ndims(masks) == 3
	se = strel('arbitrary',ones(kernelsize,kernelsize,kernelsize));
else
	se = strel('disk',kernelsize);
end



N = floor(log2(max(single(masks(:)))))+1;
for k = 1:N
	maskbit = bitget(masks,k);

	switch action
		case 'expanding'
			temp_maskbit_out = imdilate(maskbit,se);
		case 'shrinking'
			temp_maskbit_out = imerode(maskbit,se);
		case 'smoothing'
			temp_maskbit_out = imclose(imopen(maskbit,se),se);
	end
	
	if k == 1
		masksout = temp_maskbit_out;
	else
		temp_maskbit_out = imdilate(maskbit,se);
		masksout = bitor(masksout,bitshift(temp_maskbit_out,k-1));
	end
end


