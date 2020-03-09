function masks_out = deform_structure_masks(masks,mvy,mvx,mvz)
%{
	masks = deform_structure_masks(masks,mvy,mvx,mvz)


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

N = floor(log2(max(single(masks(:)))))+1;

for k = 1:N
	maskbit = bitget(uint32(masks),k);
	
	if k == 1
% 		masks_out = uint32(round(move3dimage(single(maskbit),mvy,mvx,mvz,'nearest')));
		masks_out = deform_1_structure_mask(maskbit,mvy,mvx,mvz);
	else
% 		temp_masks_out = uint32(round(move3dimage(single(maskbit),mvy,mvx,mvz,'nearest')));
		temp_masks_out = deform_1_structure_mask(maskbit,mvy,mvx,mvz);
		masks_out = bitor(masks_out,bitshift(temp_masks_out,k-1));
	end
end

