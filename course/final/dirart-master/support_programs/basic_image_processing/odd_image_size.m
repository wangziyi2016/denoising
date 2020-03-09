function imgout = odd_image_size(imgin)
%
% Make the image height and width to be odd by deleting the last column and
% the last row if necessary
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

siz = size(imgin);
imgout = imgin;

if( mod(siz(1),2) == 0 )
	imgout = imgin(1:siz(1)-1,:);
end

if( mod(siz(2),2) == 0 )
	imgout = imgout(:,1:siz(2)-1);
end

