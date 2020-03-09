function imout = mri_correction_filter(im,s)
%
% Correct intensity nonuniformness of MR images
%

if( ~exist('s') )
	s = 8;
end

kernel = ones(10,'single');
kernel = kernel / sum(kernel(:));

dim = size(im);

imout = im;
for n=1:s
	imout = imenlargeby1(imout);
end

for n=1:s
	imout = lowpass2d(imout,kernel);
end

maxim = max(im(:));
imout = imout(s+1:dim(1)+s,s+1:dim(2)+s);

imout = single(im) ./ single(imout);

imout = imout / single(max(imout(:))) * single(maxim);

f = str2func(class(im));

imout = f(imout);

