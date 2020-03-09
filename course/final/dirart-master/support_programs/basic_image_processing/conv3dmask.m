function out = conv3dmask(im3d,mask3d)

masksize = size(mask3d);

if ndims(im3d) == 3
	if( prod(masksize) ~= 125 & prod(masksize) ~= 27 )
		error('Only supports 5x5x5 or 3x3x3 masks');
	end
else
	if( prod(masksize) ~= 25 & prod(masksize) ~= 9 )
		error('Only supports 5x5 or 3x3 masks for 2D');
	end
end


dim = mysize(im3d);

y0 = 1:dim(1);
x0 = 1:dim(2);
z0 = 1:dim(3);

out = zeros(dim,'single');

if dim(3) > 1
	if prod(masksize) == 125
		hi=5;
		de = 3;
	else
		hi = 3;
		de = 2;
	end
else
	if prod(masksize) == 25
		hi=5;
		de = 3;
	else
		hi = 3;
		de = 2;
	end
end

im=out;

for i=1:hi
	y = y0+i-de; y = max(y,1); y = min(y,dim(1));
	for j=1:hi
		x = x0+j-de; x = max(x,1); x = min(x,dim(2));
		if dim(3) > 1
			for k=1:hi
				z = z0+k-de; z = max(z,1); z = min(z,dim(3));
				im = im3d(y,x,z);
				out = out + im * mask3d(i,j,k);
			end
		else
			im = im3d(y,x,1);
			out = out + im * mask3d(i,j,1);
		end
	end
end

