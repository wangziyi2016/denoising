function V2 = seg_lung(V, point)
%Segmentation lung
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

point = [40,159,72];

V=single(V);
V=V/max(V(:));
V = max(V,0);

disp('Calculating image gradient ...');
[fx,fy,fz]=gradient(V);
grad = sqrt(fx.^2+fy.^2+fz.^2);

clear fx fy fz;

grad = grad/max(grad(:));
g2= (grad >0.09 & V>0.09);


disp('Finding the lung edge ...');
g3 = imfill(~g2,point,6);

g3= g3 & g2;
g4 = lowpass3d(single(g3),1);
g3 = g4 > 0.2;

clear g2 grad;

disp('Finding the outside ...');
g4 = imfill(g3,[1 1 1],6);
g4 = g4 & ~g3;

clear g3;

disp('Smoothing the result ...');
g6=lowpass3d(single(g4),1);

clear g4;

disp('Creating the output ...');
V2=V .* (g6<0.4) .* (1-g6);

clear g6;
