function masks_out = resample_structure_masks(masks,varargin)
%{
	masks = resample_structure_masks(masks,varargin)


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

N = floor(log2(max(single(masks(:)))))+1;

for k = 1:N
	fprintf('Resampling structure mask %d\n',k);
	maskbit = bitget(uint32(masks),k);
	
	if k == 1
		masks_out = uint32(round(resample_3D_image(single(maskbit), varargin{:})));
	else
		temp_masks_out = uint32(round(resample_3D_image(single(maskbit), varargin{:})));
		masks_out = bitor(masks_out,bitshift(temp_masks_out,k-1));
	end
end

