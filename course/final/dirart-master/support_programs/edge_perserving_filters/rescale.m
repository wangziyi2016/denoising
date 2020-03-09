function y = rescale(x);

m = min(x(:));
M = max(x(:));
y = (x-m)/(M-m);