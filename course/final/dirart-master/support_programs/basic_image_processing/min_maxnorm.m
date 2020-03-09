function y=min_maxnorm(x,yrange)
% normalize the dynamic range bewteen two values 
% Written by: Issam El Naqa    date: 09/12/03
% x: input image
% y: normalized image
x=double(x);
xmin=min(x(:)); xmax=max(x(:));
ymin=yrange(1); ymax=yrange(2);
y=(x-xmin)./(xmax-xmin).*(ymax-ymin)+yrange(1);
return

