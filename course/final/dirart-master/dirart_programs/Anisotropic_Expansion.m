function imgout=Anisotropic_Expansion(imgin,boundary_sizes,voxelsizes)
%{

imgout=Anisotropic_Expansion(imgin,boundary_sizes)				% boundary_sizes in voxels
imgout=Anisotropic_Expansion(imgin,boundary_sizes,voxelsizes)	% boundary_sizes in the same unit of the voxelsizes

Deshan Yang, dyang@radonc.wustl.edu
03/10/2009
Department of radiation oncology
Washington University in Saint Louis

%}

if exist('voxelsizes','var')
	boundary_sizes = boundary_sizes ./ voxelsizes;
end

boundary_sizes = ceil(boundary_sizes);
% G = gaussian_kernel(boundary_sizes/4);
% G = gaussian_kernel(boundary_sizes/10);
G = gaussian_kernel([4 4 4].*boundary_sizes/max(boundary_sizes));

% Set the center of the kernel to 0
[maxG,maxidx] = max(G(:));
[cy,cx,cz]=ind2sub(size(G),maxidx);
G(cy,cx,cz) = 0;
G = G / sum(G(:));	% Renormalize G

dimin = size(imgin);
ys = 1:dimin(1);
xs = 1:dimin(2);
zs = 1:dimin(3);
ys2 = ys+boundary_sizes(1);
xs2 = xs+boundary_sizes(2);
zs2 = zs+boundary_sizes(3);

imgout = zeros(dimin+boundary_sizes*2);
imgout(ys2,xs2,zs2) = imgin;

for k = 1:max(boundary_sizes/2)
	imgout = conv3fft(imgout,G);
	imgout(ys2,xs2,zs2) = imgin;	% Reset the source
end

