function out = conv2fft(z1,z2)

z1 = single(z1);
z2 = single(z2);

siz1 = size(z1);
siz2 = size(z2);

siz = siz1+siz2-1;

out=real(ifft2(fft2(z1,siz(1),siz(2)).*fft2(z2,siz(1),siz(2))));

p = ((siz2-1)+mod((siz2-1),2))/2;

out=out(p(1)+1:p(1)+siz1(1),p(2)+1:p(2)+siz1(2));
