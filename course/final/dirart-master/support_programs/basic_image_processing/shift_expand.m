function [im1,im2] = shift_expand(ima,imb,x,y)
%
% Function: [im1,im2] = shift_expand(ima,imb,x,y)
%
% Translate the image B by x and y pixels, then expand both image A and B
% to the same dimension. Two images were initialized aligned in their centers.
% Empty space will be filled by NaN.
%
% By: Deshan Yang, 05/2006
%

ima = double(ima);
imb = double(imb);

x = round(x);
y = round(y);

if( x ~= 0 | y ~= 0 )
	sizb = size(imb);
	neww = sizb(2)+2*abs(x);
	newh = sizb(1)+2*abs(y);

	newb = NaN(newh,neww);
	newb(abs(y)+y+1:abs(y)+y+sizb(1),abs(x)+x+1:abs(x)+x+sizb(2)) = imb;
	imb = newb;
end

% Patch the smaller image with NaN boundary to be the same size as the
% bigger image


siza = size(ima);
sizb = size(imb);

% For the vertical size
if( siza(1) ~= sizb(1) )
	dif = abs(siza(1) - sizb(1));
	up = round(dif/2);
	low = dif - up;
	
	if( siza(1) < sizb(1) )
		ima = [nan(up,siza(2));ima;nan(low,siza(2))];
		siza = size(ima);
	else
		imb = [nan(up,sizb(2));imb;nan(low,sizb(2))];
		sizb = size(imb);
	end
end


% For the horizontal size
if( siza(2) ~= sizb(2) )
	dif = abs(siza(2) - sizb(2));
	lf = round(dif/2);
	rt = dif - lf;
	
	if( siza(2) < sizb(2) )
		ima = [nan(siza(1),lf) ima nan(siza(1),rt)];
	else
		imb = [nan(sizb(1),lf) imb nan(sizb(1),rt)];
	end
end

% Delete the NaN boundaries

sizc = size(ima);

c1 = isnan(ima);
c2 = isnan(imb);
na_col = sum(c1,2);
na_row = sum(c1,1);
nb_col = sum(c2,2);
nb_row = sum(c2,1);

left = min(find(na_row+nb_row < 2*sizc(1)));
right = max(find(na_row+nb_row < 2*sizc(1)));
top = min(find(na_col+nb_col < 2*sizc(2)));
bottom = max(find(na_col+nb_col < 2*sizc(2)));

im1 = ima(top:bottom,left:right);
im2 = imb(top:bottom,left:right);







