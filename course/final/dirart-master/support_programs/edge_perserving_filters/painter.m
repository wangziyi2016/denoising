function out = painter(img, sgm, N, q)

img = allarga(img, ceil(1.5*sgm));

I1 = img(:,:,1); I2 = img(:,:,2); I3 = img(:,:,3);

[nr, nc] = size(I1);

u = linspace(-nc/2, nc/2, nc);
v = linspace(nr/2, -nr/2, nr);
[x,y] = meshgrid(u,v);
gaux = exp(-(x.^2+y.^2)/(2*sgm^2));

imW1  = fft2(I1);    imW2  = fft2(I2);    imW3  = fft2(I3);
im2W1 = fft2(I1.^2); im2W2 = fft2(I2.^2); im2W3 = fft2(I3.^2);

S = spicchi(N, sgm/4, nr,nc);
for i = 1:N
    GA = gaux .* S(:,:,i); 
    GA = GA / sum(GA(:));
    GAW = fft2(GA);
    
    avg(:,:,i,1) = fftshift(real(ifft2(imW1 .* GAW)));
    avg(:,:,i,2) = fftshift(real(ifft2(imW2 .* GAW)));
    avg(:,:,i,3) = fftshift(real(ifft2(imW3 .* GAW)));
    
    
    SG(:,:,i,1)   = fftshift(real(ifft2(im2W1.* GAW))) - avg(:,:,i,1).^2;
    SG(:,:,i,2)   = fftshift(real(ifft2(im2W2.* GAW))) - avg(:,:,i,2).^2;
    SG(:,:,i,3)   = fftshift(real(ifft2(im2W3.* GAW))) - avg(:,:,i,3).^2;
end

SGM = (sum(SG, 4)+0.00001).^-q;


S = sum(SGM,3);

for i = 1:3
    y(:,:,i) = sum(avg(:,:,:,i).*SGM, 3) ./ S; %) .* (S~=0) + img(:,:,i).*(S==0);
end

out = rescale(y);
out = restringi(out, ceil(1.5*sgm));

    
    