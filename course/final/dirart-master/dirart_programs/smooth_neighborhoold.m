function out = smooth_neighborhoold(im3d,neighboresize,sigmas,lambda_s,lambda_g)
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

out = zeros(dim,'single');
im=out;

de = (neighboresize+1)/2;
sigmas2 = sigmas.*sigmas;
sigmas2 = sigmas2 + (sigmas2==0);

% Compute distance mask
Mdist = zeros([neighboresize,neighboresize,neighboresize],'single');
Mg = out;
Ms = out;
sum1=out;
sum2=out;

H = waitbar(0,'Smooth neighborhood');
set(H,'Name','Smooth neighborhood');
set(H,'NumberTitle','off');

for i=1:neighboresize
	y = y0+i-de; y = max(y,1); y = min(y,dim(1));
	for j=1:neighboresize
		x = x0+j-de; x = max(x,1); x = min(x,dim(2));
		for k=1:neighboresize
			waitbar(((i-1)*25+(j-1)*5+k-1)/125,H,sprintf('Smooth neighborhood: %d - %d - %d',i,j,k));
			Mdist = exp(-sqrt((i-3).^2+(j-3).^2+(k-3).^2)/lambda_s);

			z = z0+k-de; z = max(z,1); z = min(z,dim(3));
			im = im3d(y,x,z);
			
			Mg = exp(-((im3d-im).^2)/lambda_g./sigmas2);
			Ms = Mg*Mdist;
	
			sum1 = sum1+Ms.*im;
			sum2 = sum2+Ms;
		end
	end
end

out = sum1./sum2;
close(H);


