function newimg = GPReduce2(img,blocksize,displayflag)
%{
Performing image down sampling using GPReduce function

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}
if ~exist('displayflag')
	displayflag = 1;
end

dim = size(img);

newimg = [];
for b = 1:blocksize:dim(3)
	img2 = img(:,:,b:b+blocksize-1);
	newimg2 = GPReduce(img2,displayflag);
	newimg = cat(3,newimg,newimg2);
end
