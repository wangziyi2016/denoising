function [varargout] = fast3dconv(mask3d,varargin)
%{
Fast 3D convolution

[varargout] = fast3dconv(mask3d,varargin)


Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

masksize = size(mask3d);
if( prod(masksize) ~= 125 & prod(masksize) ~= 27 )
	error('Only supports 5x5x5 or 3x3x3 masks');
end

if nargin ~= nargout+1
	error('Number of outputs must be the same as number of inputs');
end

dim = size(varargin{1});
y0 = 1:dim(1);
x0 = 1:dim(2);
z0 = 1:dim(3);

im = zeros(dim,'single');
for k=1:nargout
	varargout{k} = im;
end

if prod(masksize) == 125
	hi=5;
	de = 3;
else
	hi = 3;
	de = 2;
end

N = nargin-1;

for i=1:hi
	y = y0+i-de; y = max(y,1); y = min(y,dim(1));
	for j=1:hi
		x = x0+j-de; x = max(x,1); x = min(x,dim(2));
		for k=1:hi
			z = z0+k-de; z = max(z,1); z = min(z,dim(3));
			for n = 1:N
				im = varargin{n}(y,x,z);
				varargout{n} = varargout{n} + im * mask3d(i,j,k);
			end
		end
	end
end

