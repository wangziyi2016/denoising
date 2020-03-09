function y = smoothing(name, namesave, sgm, NS, q)
if ischar(name)
	img = double(imread(name))/255;
else
	img = name;
end

epsilon = 10^-4;
[nr, nc, N] = size(img);

[x,y] = meshgrid(linspace(-nc/2, nc/2, nc), linspace(nr/2, -nr/2, nr));
gaux = exp( -(x.^2+y.^2) / (2*sgm^2) );


for i = 1 : N
    imW(:,:,i)  = fft2(img(:,:,i));
    im2W(:,:,i) = fft2(img(:,:,i).^2);
end

num = zeros(nr,nc,N);
den = zeros(nr,nc);
for i = 0 : NS-1
    G = smoothgaux(sector(nr,nc, i*2*pi/NS, pi/NS), 1, 2.5) .* gaux;
    G = G / sum(G(:));
    G = fft2(G);
    
    S = zeros(nr,nc);
    for k = 1 : N
        m(:,:,k) = ifft2(G .* imW(:,:,k));
        S = S +    ifft2(G .* im2W(:,:,k)) - m(:,:,k).^2;
    end
    
    S = (S+epsilon).^(-q/2);
    den = den + S;
    for k = 1 : N
        num(:,:,k) = num(:,:,k) + m(:,:,k).*S;
    end
   
end

for k = 1 : N
    y(:,:,k) = fftshift(num(:,:,k) ./ den);
end

if ~isempty(namesave)
	imwrite(y, namesave);
end
