function h2 = deform_all_contours(handles, h2)
%
% This function will use the computed motion field to deform 1 structure in
% the planC and put the results into the dst_planC.
%

indexS = planC{end};
indexS2 = dst_planC{end};

% %return if strnum is already associated to scanIndex
assocScanNum = getAssociatedScan(planC{indexS.structures}(strnum).assocScanUID);

%set Matlab path to directory containing the Mesh-library
currDir = cd;
meshDir = fileparts(which('libMeshContour.dll'));
cd(meshDir)
loadlibrary('libMeshContour','MeshContour.h')

%Create Mesh-representation if it does not exist
clearMeshFlag = 0;
if ~isfield(planC{indexS.structures}(strnum),'meshRep') || (isfield(planC{indexS.structures}(strnum),'meshRep') && (isempty(planC{indexS.structures}(strnum).meshRep) || planC{indexS.structures}(strnum).meshRep == 0))
    assocScan = getStructureAssociatedScan(strnum,planC);
    [xVals, yVals, zVals] = getScanXYZVals(planC{indexS.scan}(assocScan));
    structUID   = planC{indexS.structures}(strnum).strUID;
    [rasterSegments, planC, isError]    = getRasterSegments(strnum);
    [mask3M, uniqueSlices] = rasterToMask(rasterSegments, assocScan);
    mask3M = permute(mask3M,[2 1 3]);
    smoothIter = 2;
    calllib('libMeshContour','clear','structUID')
    calllib('libMeshContour','loadVolumeAndGenerateSurface',structUID,xVals,yVals,zVals(uniqueSlices), double(mask3M),0.5, uint16(smoothIter))
    %Store mesh under planC
    planC{indexS.structures}(strnum).meshS = calllib('libMeshContour','getSurface',structUID);
    clearMeshFlag = 1;
end


%Deform the vertices and normals of the mesh
vertices = planC{indexS.structures}(strnum).meshS.vertices;
xInterpV = vertices(:,1);
yInterpV = vertices(:,2);
zInterpV = vertices(:,3);

outOfBoundsVal = 0;
xFieldV = [xDeform(1) xDeform(2)-xDeform(1) xDeform(end)];
yFieldV = [yDeform(1) yDeform(2)-yDeform(1) yDeform(end)];
xVertices = finterp3(xInterpV, yInterpV, zInterpV, xDeform3M, xFieldV, yFieldV, zDeform, outOfBoundsVal);
yVertices = finterp3(xInterpV, yInterpV, zInterpV, yDeform3M, xFieldV, yFieldV, zDeform, outOfBoundsVal);
zVertices = finterp3(xInterpV, yInterpV, zInterpV, zDeform3M, xFieldV, yFieldV, zDeform, outOfBoundsVal);

deformedVertices = [xInterpV+xVertices(:) yInterpV+yVertices(:) zInterpV+zVertices(:)];
deformedMeshS = planC{indexS.structures}(strnum).meshS;
deformedMeshS.vertices = deformedVertices;


%Recompute vertex normals
deformedMeshS.normals = [];
for i=1:length(deformedVertices)
    %deformedMeshS.normals(i,:) = calcVertexNormal(i,deformedVertices);
    deformedMeshS.normals(i,:) = calcVertexNormal(i,deformedMeshS);
end

%Load the surface
newStruct = newCERRStructure(scanIndex, planC);
calllib('libMeshContour','loadSurface',newStruct.strUID,deformedMeshS);
newStruct.structureName = [planC{indexS.structures}(strnum).structureName,'_deformed'];

%Get transformation matrix
if ~isfield(planC{indexS.scan}(scanIndex),'transM') || isempty(planC{indexS.scan}(scanIndex).transM)
    transMnew = eye(4);
else    
    transMnew = planC{indexS.scan}(scanIndex).transM;
end
if ~isfield(planC{indexS.scan}(assocScanNum),'transM') || isempty(planC{indexS.scan}(assocScanNum).transM) 
    transMold = eye(4);
else    
    transMold = planC{indexS.scan}(assocScanNum).transM;
end
transM = inv(transMnew)*transMold;

%Cut the surface at slice z-values and create CERR contour
[jnkX, jnkY, scanZv] = getScanXYZVals(planC{indexS.scan}(scanIndex));
for i=1:length(scanZv)
    coord = scanZv(i);
    pointOnPlane = [0 0 coord] - transM(1:3,4)';
    planeNormal = (inv(transM(1:3,1:3))*[0 0 1]')';
    pointOnPlane = (inv(transM(1:3,1:3))*pointOnPlane')';
    %structUID   = planC{indexS.structures}(strnum).strUID;
    structUID   = newStruct.strUID;
    contourS    = calllib('libMeshContour','getContours',structUID,single(pointOnPlane),single(planeNormal),single([0 1 0]),single([1 0 0]));
    if ~isempty(contourS) && length(length(contourS.segments)) > 0
		segments = ConnectContourSegments(contourS.segments);
        for segNum = 1:length(segments)
            pointsM = applyTransM(transM,segments(segNum).points);
            contour_str(i).segments(segNum).points(:,1) = pointsM(:,1);
            contour_str(i).segments(segNum).points(:,2) = pointsM(:,2);
            contour_str(i).segments(segNum).points(:,3) = coord*pointsM(:,1).^0;
        end
    else
        contour_str(i).segments(1).points = [];
    end
end
%Clear Surface Mesh
if clearMeshFlag
    planC{indexS.structures}(strnum).meshRep = 0;
    planC{indexS.structures}(strnum).meshS = [];
end

%Chenge directory back
cd(currDir)

newStruct.contour = contour_str;
newStruct.associatedScan = scanIndex;
newStruct.assocScanUID = planC{indexS.scan}(scanIndex).scanUID;
newStruct.meshRep = 0;
numStructs = length(planC{indexS.structures});

%Append new structure to planC.
planC{indexS.structures} = dissimilarInsert(planC{indexS.structures}, newStruct, numStructs+1, []);

%Create Raster Segments
planC = getRasterSegs(planC, numStructs+1);

%Update uniformized data.
planC = updateStructureMatrices(planC, numStructs+1);

stateS.structsChanged = 1;
CERRRefresh

return;

