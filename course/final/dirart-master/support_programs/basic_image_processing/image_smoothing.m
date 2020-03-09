function imout = image_smoothing(imin)

imout = imin;
dt = 0.01;

%figure;imagesc(imin);colormap('gray');daspect([1 1 1]);
for iter = 1:10
	[Fgrad, kappa,fx,fy]=curve_derivatives_2(imout);
	fx = fx./(1+Fgrad.^2);
	fy = fy./(1+Fgrad.^2);
	imout = imout + dt * divergence(fx,fy);
%	imagesc(imout);colormap('gray');daspect([1 1 1]);
end