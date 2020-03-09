function y = removeframe(img, N)

%In combination with the function addframe.m, this function prevents the
%border effects related to the FFT.

[nr,nc, NN] = size(img);
y = img(N+1 : nr-N, N+1 : nc-N, :);