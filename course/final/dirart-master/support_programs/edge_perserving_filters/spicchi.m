function S = sectors(N, sgm, nr, nc);

%This function generates the sectors wi(x,y) (see (5) in the paper).

n = 3;
sgm = ceil(sgm);

c1 = -nc/2-2*n*sgm;
c2 = nc/2+2*n*sgm;
c3 = nc+4*n*sgm;
u = linspace(c1, c2, c3);

r1 = nr/2+2*n*sgm;
r2 = -nr/2-2*n*sgm;
r3 = nr+4*n*sgm;
v = linspace(r1, r2, r3);

[x,y] = meshgrid(u,v);

if sgm ~= 0
    gaux = exp(-(x.^2+y.^2)/(2*sgm^2));
    gaux = gaux / sum(gaux(:));
    gauW = fft2(gaux);
end

for i = 1:N
    fi1 = (i-1)* 2*pi/N + pi/N;
    fi2 = i    * 2*pi/N + pi/N;
    X1 = x*cos(fi1) + y*sin(fi1);
    X2 = x*cos(fi2) + y*sin(fi2);
    A = (X1>0) .* (X2<0);

    A(1:n*sgm, :) = 0;
    A(nr+1+3*n*sgm:nr+4*n*sgm, :) = 0;
    A(:, 1:n*sgm) = 0;
    A(:, nc+1+3*n*sgm:nc+4*n*sgm) = 0;

    if sgm ~=0
        A = fftshift(real(ifft2(fft2(A) .* gauW)));
    end

    S(:,:,i) = A(2*n*sgm+1 : nr+2*n*sgm, 2*n*sgm+1 : nc+2*n*sgm);
end