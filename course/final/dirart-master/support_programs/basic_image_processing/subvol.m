function Aout = subvol(A,newdim,offsets)
%
% Aout = subvolume(A,newdim,offsets)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

x0 = 1:newdim(2); x0 = x0+offsets(2);
y0 = 1:newdim(1); y0 = y0+offsets(1);

if ndims(A) == 3
	z0 = 1:newdim(3); z0 = z0+offsets(3);
	Aout = A(y0,x0,z0);
else
	Aout = A(y0,x0);
end



