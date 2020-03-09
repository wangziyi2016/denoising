function newStruct = SmoothStructureMorphological(struct1,img)
%
%	newStruct = SmoothStructureMorphological(struct1,img)
%

prompt={'Enter smoothing kernel size (mm)'};
name='Enter kernel size';
numlines=1;
disc = 4;
defaultanswer={num2str(disc)}; 
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	disc = str2double(answer{1});
	disc = max(disc,1);
else
	newStruct = [];
	return;
end

[mask3M,yVals,xVals,zVals] = MakeStructureMask(struct1,img,2);
dx = abs(xVals(2)-xVals(1));
dy = abs(yVals(2)-yVals(1));
dz = abs(zVals(2)-zVals(1));
discx = ceil(disc/dx);
discy = ceil(disc/dy);
discz = ceil(disc/dz);

se = strel('arbitrary',ones(discy,discx,discz));

mask3Mpadded = padarray(mask3M,double([discy,discx,discz])*2);
mask3Mpadded=imclose(imopen(mask3Mpadded,se),se);	% smoothing
dim = size(mask3M);
mask3M = mask3Mpadded((1:dim(1))+discy*2,(1:dim(2))+discx*2,(1:dim(3))+discz*2);

mask3M = permute(mask3M,[2 1 3]);
newStruct = RebuiltStructure(struct1,mask3M,xVals,yVals,zVals);
newStruct.structureName = [newStruct.structureName '_smoothed'];

