function IResult = MeanReduce(I,display)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(I);
newdim = ceil(dim*0.5);

y0 = 1:2:dim(1);
x0 = 1:2:dim(2);
z0 = 1:2:dim(3);

temp = zeros([newdim 8],class(I));

for i = 0:1
	for j=0:1
		for k=0:1
			y1 = min(y0+i,dim(1));
			x1 = min(x0+j,dim(2));
			z1 = min(z0+k,dim(3));
			temp(:,:,:,i*4+j*2+k+1) = I(y1,x1,z1);
		end
	end
end

IResult = mean(temp,4);
