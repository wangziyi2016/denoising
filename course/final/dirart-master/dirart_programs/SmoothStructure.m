function newStruct = SmoothStructure(struct1,img)
%
%	newStruct = SmoothStructure(struct1,img)
%
button = questdlg('Use interative mesh-based smoothing, or morphological smoothing?','Structure smoothing','Mesh-based','Morphological','Cancel','Morphological');
if strcmpi(button,'cancel') == 1
	newStruct = [];
elseif strcmpi(button,'Mesh-based') == 1
	newStruct = SmoothStructureByMeshIteratively(struct1,img);
else
	newStruct = SmoothStructureMorphological(struct1,img);
end


