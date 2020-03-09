function [masks_2,masks_4,masks_8,masks_16]=Multigrid_Downsample_Structure_Masks(masks,levels)
%{
	[masks_2,masks_4,masks_8,masks_16]=Multigrid_Downsample_Structure_Masks(masks,levels)

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

N = floor(log2(max(single(masks(:)))))+1;

func = @MeanReduce;
% func = @MaxReduce;

for k = 1:N
	maskbit = bitget(uint32(masks),k);
	
	if k == 1
		masks_2 = uint32(round(func(single(maskbit))));
		masks_4 = uint32(round(func(single(masks_2))));
		masks_8 = uint32(round(func(single(masks_4))));
		if levels > 4
			masks_16 = uint32(round(func(single(masks_8))));
		end
	else
		temp_masks_2 = uint32(round(func(single(maskbit))));
		temp_masks_4 = uint32(round(func(single(temp_masks_2))));
		temp_masks_8 = uint32(round(func(single(temp_masks_4))));
		
		masks_2 = bitor(masks_2,bitshift(temp_masks_2,k-1));
		masks_4 = bitor(masks_4,bitshift(temp_masks_4,k-1));
		masks_8 = bitor(masks_8,bitshift(temp_masks_8,k-1));

		if levels > 4
			temp_masks_16 = uint32(round(func(single(temp_masks_8))));
			masks_16 = bitor(masks_16,bitshift(temp_masks_16,k-1));
		end
	end
end

			