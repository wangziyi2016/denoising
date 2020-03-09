function newsegments = ConnectContourSegments(segments)
%
%	newsegments = ConnectContourSegments(segments)
%

N = length(segments);
if N <= 1
	newsegments = segments;
	return;
end

used = zeros(1,N);

delta = 0.1;	% 2 mm

newsegno = 0;
for k = 1:N
	if used(k) > 0
		continue;
	end

	points = segments(k).points;
	newsegno = newsegno+1;
	used(k) = 1;

	while 1
		found = 0;
		for m = 1:N
			if used(m) > 0
				continue;
			end

			pointsm = segments(m).points;

			if ComputeDist(points(1,:),pointsm(1,:)) < delta
				used(m) = 1;
				found = 1;
				points = joint_points(points,pointsm,1);
			elseif ComputeDist(points(end,:),pointsm(1,:)) < delta
				used(m) = 1;
				found = 1;
				points = joint_points(points,pointsm,2);
			elseif ComputeDist(points(end,:),pointsm(end,:)) < delta
				used(m) = 1;
				found = 1;
				points = joint_points(points,pointsm,3);
			elseif ComputeDist(points(1,:),pointsm(end,:)) < delta
				used(m) = 1;
				found = 1;
				points = joint_points(points,pointsm,4);
			end
		end
		
		if found == 0
			break;
		end
	end
	newsegments(newsegno).points = points;
end
return;

function dist = ComputeDist(point1,point2)
dist = sqrt(sum((point1-point2).^2));
return;

function newpoints = joint_points(points1,points2,position)
% L1 = size(points1,1);
L2 = size(points2,1);
switch position
	case 1
		newpoints = [points2(L2:-1:1,:);points1];
	case 2
		newpoints = [points1;points2];
	case 3
		newpoints = [points1;points2(L2:-1:1,:)];
	case 4
		newpoints = [points2;points1];
end
return;

