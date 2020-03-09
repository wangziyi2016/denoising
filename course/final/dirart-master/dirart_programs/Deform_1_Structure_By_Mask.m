function newStruct = Deform_1_Structure_By_Mask(handles,strnum)
%
%	newStruct = Deform_1_Structure_By_Mask(handles,strnum)
%	newStruct = Deform_1_Structure_By_Mask(handles,struct2deform)
%
% This function will use the computed motion field to deform 1 structure
%

if isstruct(strnum)
	struct2deform = strnum;
else
	struct2deform = GetElement(handles.ART.structures,strnum);
end

% %return if strnum is already associated to scanIndex
imgidx = handles.ART.structure_assocImgIdxes(strnum);
[mask3M,yVals,xVals,zVals] = MakeStructureMask(struct2deform,[],2);

img = handles.images(3-imgidx);
if imgidx == 1
	dvf = handles.reg.dvf;
else
	dvf = handles.reg.idvf;
end

% [dummy,dummy,zValsOut] = get_image_XYZ_vectors(img);
[dummy,dummy,zValsOut] = get_image_XYZ_vectors(handles.images(imgidx));

[yVals2,xVals2,zVals2] = get_image_XYZ_vectors(dvf.info,size(dvf.x));
[xx,yy,zz] = meshgrid(xVals2,yVals2,zVals2);
deltay = dvf.y * dvf.info.voxelsize(1) * dvf.info.voxel_spacing_dir(1);
deltax = dvf.x * dvf.info.voxelsize(2) * dvf.info.voxel_spacing_dir(2);
deltaz = dvf.z * dvf.info.voxelsize(3) * dvf.info.voxel_spacing_dir(3);
xx = xx-deltax;
yy = yy-deltay;
zz = zz-deltaz;

% [xVals,yVals,zVals] = TranslateCoordinates(handles,imgidx,xVals,yVals,zVals);
[xx,yy,zz] = TranslateCoordinates(handles,3-imgidx,xx,yy,zz);
newMask3d = interp3wrapper(xVals,yVals,zVals,single(mask3M),xx,yy,zz,'nearest',0);
newMask3d = single(newMask3d>0.5);


%set Matlab path to directory containing the Mesh-library
currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir);
	
	%Load the surface
	newStruct = struct2deform;
	newStruct.structureName = [GetElement(handles.ART.structure_names,strnum) '_deformed'];
	setinfotext(sprintf('Creating new structure: %s ...',newStruct.structureName));
	newStruct.strUID = createUID('structure');
	
	[xVals2,yVals2,zVals2] = TranslateCoordinates(handles,3-imgidx,xVals2,yVals2,zVals2);
	
	smoothIter=0;
	newMask3d = permute(newMask3d,[2 1 3]);
	calllib('libMeshContour','clear','structUID')
	calllib('libMeshContour','loadVolumeAndGenerateSurface',newStruct.strUID,xVals2/10,yVals2/10,zVals2/10,double(newMask3d),0.5, uint16(smoothIter))
	%Store mesh under planC
	newStruct.meshS = calllib('libMeshContour','getSurface',newStruct.strUID);
	
	setinfotext('Creating contour points for every slices ...');
	newStruct = ResliceStructures(newStruct,zValsOut/10);
	%Chenge directory back
	cd(currDir)
	
	% newStruct.associatedScan = scanIndex;
	newStruct.meshRep = 1;
end


