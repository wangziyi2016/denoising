function out = conv3fft1d(z1,z2)

if IsRowVector(z1) ~= IsRowVector(z2)
	z2 = z2';
end

siz1 = size(z1);
siz2 = size(z2);
siz = siz1+siz2-1;

out=real(ifftn(fftn(z1,siz).*fftn(z2,siz)));

p = ((siz2-1)+mod((siz2-1),2))/2;
idx = IsRowVector(z1)+1;

out=out(p(idx)+1:p(idx)+siz1(idx));
