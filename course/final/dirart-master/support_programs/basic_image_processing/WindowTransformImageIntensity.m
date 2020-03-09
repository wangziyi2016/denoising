function Iout = WindowTransformImageIntensity(Iin,center,width)
%
% Iout = WindowTransformImageIntensity(Iin,center,width)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

classIin = class(Iin);
Iin = single(Iin);

maxv = center+width/2;
minv = max(center-width/2,0);

Iin(Iin>maxv) = maxv;
Iin(Iin<minv) = minv;

if minv > 0
	Iin = Iin - minv;
end

Iout = cast(Iin,classIin);




