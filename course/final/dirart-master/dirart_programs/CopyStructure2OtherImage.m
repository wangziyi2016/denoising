function newStruct = CopyStructure2OtherImage(handles,varargin)
%
%	newStruct = CopyStructure2OtherImage(handles,strnum)
%	newStruct = CopyStructure2OtherImage(handles,strdata,imgidx)
%
if nargin == 2
	strnum = varargin{1};
	strdata = GetElement(handles.ART.structures,strnum);
	imgidx = handles.ART.structure_assocImgIdxes(strnum);
else
	strdata = varargin{1};
	imgidx = varargin{2};
end

[xs,ys,zs]=TranslateCoordinates(handles,imgidx,strdata.meshS.vertices(:,1)*10,strdata.meshS.vertices(:,2)*10,strdata.meshS.vertices(:,3)*10);
newStruct = strdata;
newStruct.meshS.vertices = [xs ys zs]/10;
newStruct.strUID = createUID('structure');

[yVals2,xVals2,zVals2] = get_image_XYZ_vectors(handles.images(3-imgidx));

% Creating contour points for every slices
newStruct = ResliceStructures(newStruct,zVals2/10);
newStruct.structureName = [newStruct.structureName '_copied'];





