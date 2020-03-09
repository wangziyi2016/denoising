function newStruct = deform_1_contour_new(handles, structno)
%
% newStruct = deform_1_contour_new(handles, structno)
% newStruct = deform_1_contour_new(handles, struct2deform)
%
% This function will use the computed motion field to deform 1 structure
%

if isstruct(structno)
	struct2deform = structno;
else
	struct2deform = GetElement(handles.ART.structures,structno);
end

% %return if strnum is already associated to scanIndex
imgidx = handles.ART.structure_assocImgIdxes(structno);
[yVals,xVals,zVals] = get_image_XYZ_vectors(handles.images(imgidx));

%set Matlab path to directory containing the Mesh-library
currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir)
	
	%Deform the vertices and normals of the mesh
	vertices = struct2deform.meshS.vertices;
	vx = vertices(:,1)*10;	% cm to mm
	vy = vertices(:,2)*10;
	vz = vertices(:,3)*10;
	
	baseimgidx = handles.ART.structure_assocImgIdxes(structno);
	
	% img = handles.images(baseimgidx);
	
	if baseimgidx == 1
		dvf = handles.reg.idvf;
	else
		dvf = handles.reg.dvf;
	end
	[ys,xs,zs] = get_image_XYZ_vectors(dvf.info,size(dvf.x));
	
	setinfotext('Computing motion of contour points ...');
	outOfBoundsVal = 0;
	deltax = interp3wrapper(xs, ys, zs, dvf.x, vx, vy, vz, 'linear',outOfBoundsVal);
	deltay = interp3wrapper(xs, ys, zs, dvf.y, vx, vy, vz, 'linear',outOfBoundsVal);
	deltaz = interp3wrapper(xs, ys, zs, dvf.z, vx, vy, vz, 'linear',outOfBoundsVal);
	
	deltax = deltax * dvf.info.voxelsize(2) * dvf.info.voxel_spacing_dir(2);
	deltay = deltay * dvf.info.voxelsize(1) * dvf.info.voxel_spacing_dir(1);
	deltaz = deltaz * dvf.info.voxelsize(3) * dvf.info.voxel_spacing_dir(3);
	
	deformedVertices = [vx-deltax vy-deltay vz-deltaz];
	deformedMeshS = struct2deform.meshS;
	deformedMeshS.vertices = double(deformedVertices)/10;
	
	
	%Recompute vertex normals
	setinfotext('Computing normal vector of triangles ...');
	deformedMeshS = ComputeVertexNormals(deformedMeshS);
	
	%Load the surface
	newStruct = struct2deform;
	newStruct.structureName = [GetElement(handles.ART.structure_names,structno) '_deformed'];
	setinfotext(sprintf('Creating new structure: %s ...',newStruct.structureName));
	newStruct.strUID = createUID('structure');
	newStruct.meshS = deformedMeshS;
	calllib('libMeshContour','loadSurface',newStruct.strUID,deformedMeshS);
	
	setinfotext('Creating contour points for every slices ...');
	newStruct = ResliceStructures(newStruct,zVals/10);
	%Chenge directory back
	cd(currDir)
	
	% newStruct.associatedScan = scanIndex;
	newStruct.meshRep = 1;
end

