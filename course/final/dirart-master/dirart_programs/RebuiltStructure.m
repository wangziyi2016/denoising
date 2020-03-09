function newStruct = RebuiltStructure(oldStruct,newMask3M,xVals,yVals,zVals,smoothIter)
%
%	newStruct = RebuiltStructure(oldStruct,newMask3M,xVals,yVals,zVals,smoothIter=0)
%
%	xVals,yVals,zVals are in mm
%
if ~exist('smoothIter','var')
	smoothIter = 0;
end

% Create the new structure
currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir);
	
	newStruct = oldStruct;
	newStruct.strUID = createUID('structure');
	
	smoothIter = 0;
	xVals = double(xVals);
	yVals = double(yVals);
	zVals = double(zVals);
	
	calllib('libMeshContour','clear','structUID');
	calllib('libMeshContour','loadVolumeAndGenerateSurface',newStruct.strUID,xVals/10,yVals/10,zVals/10, double(newMask3M),0.5, uint16(smoothIter));
	newStruct.meshS = calllib('libMeshContour','getSurface',newStruct.strUID);
	
	% Creating contour points for every slices
	newStruct = ResliceStructures(newStruct,zVals/10);
	cd(currDir)
end




