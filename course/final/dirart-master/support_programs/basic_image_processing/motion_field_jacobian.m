function jcb = motion_field_jacobian(u,v,w)
%
% jcb = motion_field_jacobian(u,v,w)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(u);

[ux,uy,uz] = gradient_3d_by_mask(u);
[vx,vy,vz] = gradient_3d_by_mask(v);
[wx,wy,wz] = gradient_3d_by_mask(w);

ux = ux+1;
vy = vy+1;
wz = wz+1;

ux=ux(:);
uy=uy(:);
uz=uz(:);
vx=vx(:);
vy=vy(:);
vz=vz(:);
wx=wx(:);
wy=wy(:);
wz=wz(:);

jcb = ux.*vy.*wz+uy.*vz.*wx+uz.*vx.*wy-uz.*vy.*wx-uy.*vx.*wz-ux.*vz.*wy;

jcb = reshape(jcb,dim);


