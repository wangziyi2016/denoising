function structInfos = ProcessCERRStructures(structures)
%
% structInfos = ProcessCERRStructures(structures)
%
% Check the xmin, xmax, ymin, ymax for each structures
%
N = length(structures);
for k = 1:N
	if isempty(structures{k})
		continue;
	end
	
	info = [];
	M = length(structures{k}.contour);
	
	vx = [];
	vy = [];
	vz = [];
	
% 	countz = 0;
	zvalues = nan(1,M);
	for j = 1:M
		if isempty(structures{k}.contour(j).segments)
			continue;
		else
% 			countz = countz+1;
			for i = 1:length(structures{k}.contour(j).segments)
				seg = structures{k}.contour(j).segments(i);
				if ~isempty(seg.points)
					vx = [vx;seg.points(:,1)];
					vy = [vy;seg.points(:,2)];
					vz = [vz;seg.points(:,3)];
				end
			end
			if ~isempty(seg.points)
				zvalues(j) = seg.points(1,3);
			end
		end
	end

	info.xmin = min(vx(:))*10;
	info.xmax = max(vx(:))*10;
	info.ymin = min(vy(:))*10;
	info.ymax = max(vy(:))*10;
	info.zmin = min(vz(:))*10;
	info.zmax = max(vz(:))*10;
% 	info.numslices = length(unique(vz));
% 	info.numslices = countz;
	info.numslices = sum(1-isnan(zvalues));
	info.zvalues = zvalues*10;
	structInfos(k) = info;
end

if ~exist('structInfos','var')
	structInfos = [];
end



