function im2 = myclahe(im1)

dim = size(im1);
im2 = im1;

H = waitbar(0,'CLAHE ...');
set(H,'Name','CLAHE ...');
for k = 1: dim(3);
	waitbar(k/dim(3),H,sprintf('CLAHE: %d of %d',k,dim(3)));
	im = squeeze(im1(:,:,k));
	im2(:,:,k) = adapthisteq(im);
end

close(H);



