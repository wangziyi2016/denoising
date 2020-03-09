function [Iout,gas_pocket_mask] = paint_gas_pocket(Iin,Imask,val_gas,val,max_noise_val)
%
% Iout = paint_gas_pocket(Iin,Imask=[],val_gas=200,val=1060,max_noise_val=100)
%
% Detect the bowel gas pockets in the image Iin, and paint the gas pockets
% with val + random noises
%
% Iin				-	3D image
% Imask				-	body mask of the 3D image
% val_gas			-	threshold (max) value of gas pocket
% val				-	the image value for the gas pocket to be replace with
%						if val is empty, will use the mean intensity of the
%						neighborhood voxels
% max_noise_val		-	range of noise
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('Imask','var') || isempty(Imask)
	fprintf('Find the outer body mask ...\n');
	Imask = segment_body(Iin);
end

fprintf('Shrinking the body mask ...\n');
Imask = imerode(Imask,strel('disk',10));

if ~exist('val_gas','var') || isempty(val_gas)
	val_gas = 800;
end

if ~exist('max_noise_val','var') || isempty(max_noise_val)
	max_noise_val = 20;
end

fprintf('Painting the gas pockets ...\n');
gas_pocket_mask = Iin<val_gas & Imask;
Iout = Iin;

idxes = find(gas_pocket_mask>0);
if isempty(idxes)
	fprintf('No bowel gas pockets found. \n');
	return;
end

gas_pocket_mask2 = imdilate(gas_pocket_mask,strel('disk',2));

if ~exist('val','var') || isempty(val)
	% compute the mean voxel intensity in the ring
	gas_pocket_mask3 = imdilate(gas_pocket_mask2,strel('disk',2));
	ring_mask = gas_pocket_mask3 & ~gas_pocket_mask2;
	if max(ring_mask(:)) > 0
		val = median(Iin(ring_mask));
% 		val = max(Iin(ring_mask));
	else
		val = 1100;
	end
end

val = 1100;

Iout(idxes) = val + (rand(1,length(idxes))-0.5)*max_noise_val;

if ~isnan(val)
	fprintf('Blurring the gas pocket boundaries ...\n');
	gas_pocket_mask_blur = lowpass3d(single(gas_pocket_mask2),2);
	%gas_pocket_mask2 = gas_pocket_mask_blur > 0;
	%boundary_mask = gas_pocket_mask2 - gas_pocket_mask;

	Iout2 = lowpass3d(Iout,2);
	boudary_mix = single(Iin).*(1-gas_pocket_mask_blur)+single(Iout2).*gas_pocket_mask_blur;

	Iout(gas_pocket_mask_blur>0) = boudary_mix(gas_pocket_mask_blur>0);
	Iout(Iout<0) = 0;
end

Iout = cast(Iout,class(Iin));






