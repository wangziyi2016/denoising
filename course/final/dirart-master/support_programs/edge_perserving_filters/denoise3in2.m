function B = denoise3in2(filter,A,varargin)
%
% Apply 2D denoise filtering to each slice of the 3D image
%
% B = denoise3in2(filter,A,varargin)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim = mysize(A);
Aclass = class(A);
A = double(A);
maxA = max(A(:));
A = A / maxA;

for k = 1:dim(3)
	fprintf('.');
	if nargin > 2
		B(:,:,k) = denoise_img(filter,A(:,:,k),varargin{:});
	else
		B(:,:,k) = denoise_img(filter,A(:,:,k));
	end
	drawnow;
end
fprintf('\n');

B = B * maxA;
B = cast(B,Aclass);

