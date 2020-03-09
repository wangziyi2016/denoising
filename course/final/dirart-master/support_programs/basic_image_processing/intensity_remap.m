function im2 = intensity_remap(im,method)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

im = single(im);

if( max(im(:)) > 1 )
	im(:) = im(:) / max(im(:));
end

im = max(im,0);

switch method
	case 1
		im2 = sqrt(im*2-im.*im);
	case 2
		im2 = 1-sqrt(1-im.*im);
	case 3
		im2 = 2 - sqrt( 5 - (im+1).^2 );
end


