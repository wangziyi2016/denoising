function newStruct = SmoothStructureByMeshIteratively(struct1,img)
%
%	newStruct = SmoothStructureByMeshIteratively(struct1,img)
%

prompt={'Number of iterations:'};
name='Structure smoothing';
numlines=1;
defaultanswer={'2'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if ~isempty(answer)
	smoothIter = round(str2double(answer{1}));
	smoothIter = max(smoothIter,1);
	smoothIter = min(smoothIter,10);
else
	newStruct = [];
	return;
end

[mask3M,yVals,xVals,zVals] = MakeStructureMask(struct1,img);
mask3M = permute(mask3M,[2 1 3]);
newStruct = RebuiltStructure(struct1,mask3M,xVals,yVals,zVals,smoothIter);
newStruct.structureName = [newStruct.structureName '_smoothed'];


