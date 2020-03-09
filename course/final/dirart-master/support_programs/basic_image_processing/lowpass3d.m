function  im2=lowpass3d(im,sigma_or_mask)
% Function: im = lowpass3d(im,sigma_or_mask)
%
% if sigma_or_mask is a scalar value, it will be used a the sigma value for
% the Gaussian smoothly mask. Or it must be a 3D array to be used as a 3D
% smoothly mask, and the dimensions must be odd.
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

siz=size(im);
minim = min(im(:));

if ndims(im) == 2
	im2 = lowpass2d(im,sigma_or_mask);
	return;
end


if( ndims(sigma_or_mask) ~= 3 )
	if length(sigma_or_mask) == 1
		% Gaussian smoothing
		sigma = sigma_or_mask(1);

		w=max(2*sigma,3);

		wc=floor(w/2);
		vec=[-wc:wc];
		[x,y,z] = meshgrid(vec,vec,vec);

		v = (x.*x+y.*y+z.*z)/8/sigma;

		G = sigma.^(-0.5)*exp(-v);
		G = G / sum(G(:));
	else
		% Gaussian smoothing, but different sigma for different axis
		sigma = sigma_or_mask(1);

		w=max(2*sigma_or_mask(1),3);
		wc=floor(w/2);
		vec1=[-wc:wc];
		if sigma_or_mask(1) == 0
			vec1 = 0;
		end
		

		w=max(2*sigma_or_mask(2),3);
		wc=floor(w/2);
		vec2=[-wc:wc];
		if sigma_or_mask(2) == 0
			vec2 = 0;
		end

		w=max(2*sigma_or_mask(3),3);
		wc=floor(w/2);
		vec3=[-wc:wc];
		if sigma_or_mask(3) == 0
			vec3 = 0;
		end
		
		[x,y,z] = meshgrid(vec2,vec1,vec3);

% 		v = (x.*x+y.*y+z.*z)/8/sigma;
		if sigma_or_mask(3) ~= 0
			v = (x.*x/sigma_or_mask(2) + y.*y/sigma_or_mask(1) + z.*z/sigma_or_mask(3))/8;
		else
			v = (x.*x/sigma_or_mask(2) + y.*y/sigma_or_mask(1))/8;
		end

		G = sigma.^(-0.5)*exp(-v);
		G = G / sum(G(:));
	end
else
	G = sigma_or_mask;
end

siz1 = size(im);
siz2 = size(G);
if length(siz2) == 2
	siz2 = [siz2 1];
end

siz = siz1+siz2-1;

pad = (siz2-1)/2;

im2 = zeros(siz,class(im));
im2(pad(1)+1:end-pad(1),pad(2)+1:end-pad(2),pad(3)+1:end-pad(3)) = im;
for k=1:pad
	im2(k,:,:) = im2(pad(1)+k,:,:);
	im2(end-k+1,:,:) = im2(end-pad(1)+1-k,:,:);
	
	im2(:,k,:) = im2(:,pad(2)+k,:);
	im2(:,end-k+1,:) = im2(:,end-pad(2)+1-k,:);
	
	im2(:,:,k) = im2(:,:,pad(3)+k);
	im2(:,:,end-k+1) = im2(:,:,end-pad(3)+1-k);
end


%im2 = conv3fft(im,G);
if( sum(isnan(im(:))) > 0 )
	im2 = convn(im2,G,'same');
else
	im2 = conv3fft(im2,G);
end
im2 = im2(pad(1)+1:end-pad(1),pad(2)+1:end-pad(2),pad(3)+1:end-pad(3));

if minim >= 0
	im2 = max(im2,0);
end




