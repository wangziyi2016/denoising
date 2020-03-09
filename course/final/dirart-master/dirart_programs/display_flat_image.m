function h=display_flat_image(hAxes,val)
%{
This is a supporting function used by the deformable registration GUI

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dummy = ones(20,20,3)*val;
set(gcf,'CurrentAxes',hAxes);
hold off;
h=image(dummy);
set(h,'hittest','off');
clear dummy;

