function [O1,O2,O3] = smooth_neighborhoold3(im3d,neighboresize,sigmas,lambda_s,lambda_g,A1,A2,A3)
% This function is used by the LKT deformable registration algorithm
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if( neighboresize ~= 5 & neighboresize ~= 3 )
	error('Only supports 5 or 5 neighborhood size');
end

dim = size(im3d);

y0 = 1:dim(1);
x0 = 1:dim(2);
z0 = 1:dim(3);

O1 = zeros(dim,'single');
O2 = O1;
O3 = O1;
im = O1;
Atmp = O1;

de = (neighboresize+1)/2;
sigmas2 = sigmas.*sigmas;
sigmas2 = sigmas2 + (sigmas2==0);

% Compute distance mask
Mdist = zeros([neighboresize,neighboresize,neighboresize],'single');
Mg = O1;
Ms = O1;
sum2=O1;

H = waitbar(0,'Smooth neighborhood 3');
set(H,'Name','Smooth neighborhood 3');
set(H,'NumberTitle','off');

for i=1:neighboresize
	y = y0+i-de; y = max(y,1); y = min(y,dim(1));
	for j=1:neighboresize
		x = x0+j-de; x = max(x,1); x = min(x,dim(2));
		for k=1:neighboresize
			waitbar(i*25+j*5+k/125,H,sprintf('Smooth neighborhood: %d - %d - %d',i,j,k));
			Mdist = exp(-sqrt((i-3).^2+(j-3).^2+(k-3).^2)/lambda_s);

			z = z0+k-de; z = max(z,1); z = min(z,dim(3));
			im = im3d(y,x,z);
			
			Mg = exp(-((im3d-im).^2)/lambda_g./sigmas2);
			Ms = Mg*Mdist;
	
			Atmp = A1(y,x,z); O1 = O1+Ms.*Atmp;
			Atmp = A2(y,x,z); O2 = O2+Ms.*Atmp;
			Atmp = A3(y,x,z); O3 = O3+Ms.*Atmp;
			sum2 = sum2+Ms;
		end
	end
end

O1 = O1./sum2;
O2 = O2./sum2;
O3 = O3./sum2;

close(H);

