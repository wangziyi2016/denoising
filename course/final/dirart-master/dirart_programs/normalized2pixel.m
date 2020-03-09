function vecout=normalized2pixel(vec,H)
%{
Converting MATLAB GUI object dimensions from normalized numbers to pixels

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('H','var')
	pos = get(gcf,'Position');
else
	pos = get(H,'Position');
end
vecout = vec;
vecout(1:2:end) = vecout(1:2:end)*pos(3);
vecout(2:2:end) = vecout(2:2:end)*pos(4);
return;
