function MIM = hmf(IM);
% This function filters an input image by 
% the hybrid median filter (Nieminen et al, 1987)
%
% The hybrid median filter works on the subwindows(5*5)
%
% |E - D - C|
% |- E D C -|
% |F F A B B|
% |- G H I -|
% |G - H - I|
%
% and the center A is replaced the value A'
%
% A' = median(A,median(A,B,D,F,H),med(A,C,E,G,I))
% 
% As you can see, this filter has computational load
% problem, but it works much better as a edge
% preserving median filter than the normal median filter.
%
% Reference: E.R.Davis MACHINE VISION pp75-76
%
% Input ?¨ IM: input image (color or grayscale)
% Output ?¨ MIM: output filtered image

% tic
% size of input image
dim = size(IM);
% change color image to grayscale
if length(dim)==3
    IM = rgb2gray(IM);
end

% change input image size for masking
PIM = padarray(IM,[2,2],'replicate');
% new size of input image
dim = size(PIM);

% start main loop for filtering
for m = (1+2):(dim(1,1)-2)
    for n = (1+2):(dim(1,2)-2)
        % parameters for filtering
        a = PIM(m,n);
        b1 = PIM(m,n+1);b2 = PIM(m,n+2);
        c1 = PIM(m-1,n+1);c2 = PIM(m-2,n+2);
        d1 = PIM(m-1,n);d2 = PIM(m-2,n);
        e1 = PIM(m-1,n-1);e2 = PIM(m-2,n-2);
        f1 = PIM(m,n-1);f2 = PIM(m,n-2);
        g1 = PIM(m+1,n-1);g2 = PIM(m+2,n-2);
        h1 = PIM(m+1,n);h2 = PIM(m+2,n);
        i1 = PIM(m+1,n+1);i2 = PIM(m+2,n+2);
        para1 = [a,b1,b2,d1,d2,f1,f2,h1,h2];
        para2 = [a,c1,c2,e1,e2,g1,g2,i1,i2];
        para3 = [a,median(para1),median(para2)];
        % output filtered image
        MIM(m-2,n-2) = median(para3);
    end
end
% % filtered image by median filter for comparison
% M = medfilt2(IM,[5,5]);
% figure
% subplot(2,2,1)
% imshow(M);
% title('Normal median filter')
% subplot(2,2,2)
% imshow(MIM);
% title('Hybrid median filter')
% t = toc;
