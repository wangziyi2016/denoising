function [LU,LV,LW] = vector_laplacian(U,V,W)
% Computing Laplacian of the vector fields
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ndims(U) == 3
	[GU,GV,GW] = gradient(divergence(U,V,W));

	[CU,CV,CW] = curl(U,V,W);
	[CU,CV,CW] = curl(CU,CV,CW);

	LU = GU-CU;
	LV = GV-CV;
	LW = GW-CW;
else
	[GU,GV] = gradient(divergence(U,V));

	[CU,CV] = curl(U,V);
	[CU,CV] = curl(CU,CV);

	LU = GU-CU;
	LV = GV-CV;
	LW = zeros(size(LU),class(LU));
end

