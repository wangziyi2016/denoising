function newStruct = ExpandContractStructure(struct1,img,mode)
%
%	newStruct = ExpandContractStructure(struct1,img,mode)
%
%	mode = 1:	expansion
%	mode = 2:	contractin
%

prompt={'X (LR):','Y (AP):','Z (SI):'};
name='Enter contraction / expansion dimension (mm)';
numlines=1;
defaultanswer={'3','3','3'}; 
options.Resize = 'on';
options.WindowStyle = 'modal';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	kx = str2double(answer{1});	kx = max(kx,1);
	ky = str2double(answer{2});	ky = max(ky,1);
	kz = str2double(answer{3});	kz = max(kz,1);
else
	newStruct = [];
	return;
end

[mask3M,yVals,xVals,zVals] = MakeStructureMask(struct1,img,2);
dx = abs(xVals(2)-xVals(1));
dy = abs(yVals(2)-yVals(1));
dz = abs(zVals(2)-zVals(1));
discx = ceil(kx*2/dx)+1;
discy = ceil(ky*2/dy)+1;
discz = ceil(kz*2/dz)+1;

se = strel('arbitrary',ones(discy,discx,discz));

mask3Mpadded = padarray(mask3M,double([discy,discx,discz])*2);
if mode == 1
	mask3Mpadded=imdilate(mask3Mpadded,se);	% expansion
	newname = [struct1.structureName '_expanded'];
else
	mask3Mpadded=imerode(mask3Mpadded,se);	% contraction
	newname = [struct1.structureName '_contracted'];
end
dim = size(mask3M);
mask3M = mask3Mpadded((1:dim(1))+discy*2,(1:dim(2))+discx*2,(1:dim(3))+discz*2);
mask3M = permute(mask3M,[2 1 3]);

% % Create the new structure
% currDir = pwd;
% meshDir = LoadLibMeshContour;
% cd(meshDir);
% 
% newStruct = struct1;
% newStruct.strUID = createUID('structure');
% 
% smoothIter = 0;
% calllib('libMeshContour','clear','structUID');
% calllib('libMeshContour','loadVolumeAndGenerateSurface',newStruct.strUID,xVals/10,yVals/10,zVals/10, double(mask3M),0.5, uint16(smoothIter));
% newStruct.meshS = calllib('libMeshContour','getSurface',newStruct.strUID);
% 
% % Creating contour points for every slices
% newStruct = ResliceStructures(newStruct,zVals/10);
% cd(currDir)

newStruct = RebuiltStructure(struct1,mask3M,xVals,yVals,zVals);
newStruct.structureName = newname;

