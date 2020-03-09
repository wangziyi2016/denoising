function val = principal_axes_2D(img)
%
% Function: val = principal_axes_2D(img)
%
% Calculate the primary axes of the image
%
% By: Deshan Yang, WUSTL, 06/2006
%

img = double(img);

[fx,fy] = gradient(img);

X = [fx(:) fy(:)];
C = X'*X;
[V,D] = eig(C);
val = atan(V(1,2)/V(1,1))/pi*180;

