function IResult = MeanReduce2D(I,display)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(I);
dim2 = [dim(1)/2 dim(2)/2 dim(3)];
newdim = ceil(dim2);

y0 = 1:2:dim(1);
x0 = 1:2:dim(2);
z0 = 1:dim(3);

temp = zeros([newdim 4],class(I));

for i = 0:1
	for j=0:1
		y1 = min(y0+i,dim(1));
		x1 = min(x0+j,dim(2));
		temp(:,:,:,i*2+j+1) = I(y1,x1,z0);
	end
end

IResult = mean(temp,4);
