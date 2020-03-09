function res = imrotate_nan(im,ang,method)
% function res = imrotate_nan(im,ang)
%
% Rotate the 2D image and fill the empty elements with NaN
%
% By: Deshan Yang, WUSTL, 05/2006
%

if( exist('method') == 0 )
	method = 'bilinear';
end

im = double(im);
siz = size(im);

im2 = [nan(5,siz(2));im;nan(5,siz(2))];
im3 = [nan(siz(1)+10,5) im2 nan(siz(1)+10,5)];

im4 = imrotate(im3,ang,method);

siz2 = size(im4);

for row = 1:siz2(1)
	r = find(isnan(im4(row,:)));
	if( length(r) > 0 )
		if( min(r) > 1 )
			im4(row,1:(min(r)-1)) = NaN;
		end
		
		if( max(r) < siz2(2) )
			im4(row,(max(r)+1):siz2(2)) = NaN;
		end
	end
end

im4(1,:) = NaN;
im4(:,1) = NaN;
im4(siz2(1),:) = NaN;
im4(:,siz2(2)) = NaN;

c = isnan(im4);
n1 = sum(c,1);
n2 = sum(c,2);

left = min(find(n1 < siz2(1)));
right = max(find(n1 < siz2(1)));
top = min(find(n2 < siz2(2)));
bottom = max(find(n2 < siz2(2)));

im4 = im4(top:bottom,left:right);


res = im4;

