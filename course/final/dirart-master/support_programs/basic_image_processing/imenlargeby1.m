function imout = imenlargeby1(im)

[h,w] = size(im);

imout = zeros(h+2,w+2,class(im));

imout(2:h+1,2:w+1) = im;

imout(1,2:w+1) = im(1,:);
imout(h+2,2:w+1) = im(h,:);

imout(:,1) = imout(:,2);
imout(:,w+2) = imout(:,w+1);
