function [mask3d,yVals,xVals,zVals,offs] = MakeStructureMask(handles,strnum,mode)
%
%	[mask3d,yVals,xVals,zVals] = MakeStructureMask(handles,strnum,mode)
%	[...] = MakeStructureMask(strdata,img,mode)
%	[...] = MakeStructureMask(strdata,[],mode)
%	[...,offs] = MakeStructureMask(...,mode=2)
%
%	mode = 1 (default), gives the full volume mask
%	mode = 2, give the cropped volume mask
%
if ~exist('mode','var')
	mode = 2;
end

if ~exist('strnum','var') || isempty(strnum)
	strdata = handles;
elseif isstruct(strnum)
	strdata = handles;
	img = strnum;
else
	strdata = GetElement(handles.ART.structures,strnum);
	imgidx = handles.ART.structure_assocImgIdxes(strnum);
	img = handles.images(imgidx);
end

offs = zeros(1,3);
if exist('strnum','var') && ~isempty(strnum)
	[yVals,xVals,zVals] = get_image_XYZ_vectors(img);
	if mode > 1
		structures{1} = strdata;
		info = ProcessCERRStructures(structures);

		[yVals,offs(1)] = GetVectorInRange(yVals,info.ymin,info.ymax);
		[xVals,offs(2)] = GetVectorInRange(xVals,info.xmin,info.xmax);
		[zVals,offs(3)] = GetVectorInRange(zVals,info.zmin,info.zmax);
		offs = offs - 1;
	end
else
	structures{1} = strdata;
	info = ProcessCERRStructures(structures);
	zVals = info.zvalues(~isnan(info.zvalues));
	if length(zVals)>1
		% 	zVals = info.zvalues;
		delz = zVals(2)-zVals(1);
		zVals = [zVals(1)-delz zVals zVals(end)+delz];
	end
	xVals = (info.xmin-4):2:(info.xmax+4);
	yVals = (info.ymin-4):2:(info.ymax+4);
end


M = length(xVals);
N = length(yVals);

mask3d = zeros([N,M,length(zVals)],'single');
% colors = lines(128);

for sliceNum = 1:length(zVals)
	if isnan(zVals(sliceNum))
		continue;
	end
	
	mask2d = zeros(N,M,'single');
	if ~exist('strnum','var') || isempty(strnum)
		idx = find(info.zvalues==zVals(sliceNum));
		if isempty(idx)
			segments = [];
		else
			segments = strdata.contour(idx).segments;
		end
	else
		contourS    = calllib('libMeshContour','getContours',strdata.strUID,single([0 0 zVals(sliceNum)/10]),single([0 0 1]),single([1 0 0]),single([0 1 0]));
		if ~isempty(contourS) && ~isempty(length(contourS.segments))
			segments = ConnectContourSegments(contourS.segments);
		else
			segments = [];
		end
	end
	for k = 1:length(segments)
		points = segments(k).points*10;
		x = interp1(xVals,1:M,points(:,1),'linear','extrap');
		y = interp1(yVals,1:N,points(:,2),'linear','extrap');
		mask2d = max(mask2d,poly2mask(double(x),double(y),N,M));
	end
	mask3d(:,:,sliceNum) = mask2d;
end
