function out = compute_neighborhoold_sigma(im3d,neighboresize)
%{
This is supporting function used by the LKT algorithm

Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%}

if( neighboresize ~= 5 & neighboresize ~= 3 )
	error('Only supports 5 or 5 neighborhood size');
end

dim = size(im3d);

y0 = 1:dim(1);
x0 = 1:dim(2);
z0 = 1:dim(3);

out = zeros(dim,'single');

if neighboresize == 5
	de = 3;
else
	de = 2;
end

im=out;

for i=1:neighboresize
	y = y0+i-de; y = max(y,1); y = min(y,dim(1));
	for j=1:neighboresize
		x = x0+j-de; x = max(x,1); x = min(x,dim(2));
		if dim(3) > 1
			for k=1:neighboresize
				z = z0+k-de; z = max(z,1); z = min(z,dim(3));
				im = im3d(y,x,z);
				out = out + (im-im3d).^2;
			end
		else
			im = im3d(y,x,1);
			out = out + (im-im3d).^2;
		end
	end
end

out = sqrt(out)/(neighboresize^3);


