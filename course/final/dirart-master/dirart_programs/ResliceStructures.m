function newstruct = ResliceStructures(newstruct,zVals)
%
% newstruct = ResliceStructures(newstruct,zVals)
%
currDir = pwd;
meshDir = LoadLibMeshContour;
if ~isempty(meshDir)
	cd(meshDir)
	
	calllib('libMeshContour','loadSurface',newstruct.strUID,newstruct.meshS);
	
	for i=1:length(zVals)
		coord = zVals(i);
		contourS    = calllib('libMeshContour','getContours',newstruct.strUID,single([0 0 coord]),single([0 0 1]),single([0 1 0]),single([1 0 0]));
		if ~isempty(contourS) && ~isempty(length(contourS.segments))
			segments = ConnectContourSegments(contourS.segments);
			for segNum = 1:length(segments)
				%             pointsM = applyTransM(transM,contourS.segments(segNum).points);
				pointsM = segments(segNum).points;
				contour_str(i).segments(segNum).points(:,1) = pointsM(:,1);
				contour_str(i).segments(segNum).points(:,2) = pointsM(:,2);
				contour_str(i).segments(segNum).points(:,3) = coord*ones(size(pointsM,1),1);;
			end
		else
			contour_str(i).segments = struct('points',{});
		end
	end
	
	cd(currDir);
	
	newstruct.contour = contour_str;
	newstruct.meshRep = 1;
end

