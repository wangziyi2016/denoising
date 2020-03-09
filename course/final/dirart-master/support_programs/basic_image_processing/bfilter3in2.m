function B = bfilter3in2(A,w,sigma)
%
% Apply 2D bilateral filtering to each slice of the 3D image
%
% B = bfilter3in2(A,w,sigma)
%
% BFILTER2 Two dimensional bilateral filtering.
%    This function implements 2-D bilateral filtering using
%    the method outlined in:
%
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%
%    B = bfilter2(A,W,SIGMA) performs 2-D bilateral filtering
%    for the grayscale or color image A. A should be a double
%    precision matrix of size NxMx1 or NxMx3 (i.e., grayscale
%    or color images, respectively) with normalized values in
%    the closed interval [0,1]. The half-size of the Gaussian
%    bilateral filter window is defined by W. The standard
%    deviations of the bilateral filter are given by SIGMA,
%    where the spatial-domain standard deviation is given by
%    SIGMA(1) and the intensity-domain standard deviation is
%    given by SIGMA(2).
%
% Douglas R. Lanman, Brown University, September 2006.
% dlanman@brown.edu, http://mesh.brown.edu/dlanman


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim = mysize(A);
Aclass = class(A);
A = double(A);
maxA = max(A(:));
A = A / maxA;

for k = 1:dim(3)
	fprintf('.');
	switch nargin
		case 1
			B(:,:,k) = bfilter2(A(:,:,k));
		case 2
			B(:,:,k) = bfilter2(A(:,:,k),w);
		case 3
			B(:,:,k) = bfilter2(A(:,:,k),w,sigma);
	end
	drawnow;
end
fprintf('\n');

B = B * maxA;
B = cast(B,Aclass);

