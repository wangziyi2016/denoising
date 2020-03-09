function handles = Compute_Moved_Land_Marks_Callback(handles)
%
%
%
d = handles.reg.landmark_data;

idxes1=[1 2 3];
idxes2 = [2 1 3];
if isempty(findstr(lower(handles.images(1).filename),'inhale'))
	points1 = d.points1;	% exhale
	points2 = d.points2;	% inhale
	d.moving_points = points1;
	d.fixed_points = points2;
	for i=1:3
		points1(:,idxes1(i)) = (points1(:,idxes1(i)) - d.origin1(idxes2(i)))*10 / d.spacing1(idxes2(i)) + 1;
		points2(:,idxes1(i)) = (points2(:,idxes1(i)) - d.origin2(idxes2(i)))*10 / d.spacing2(idxes2(i)) + 1;
	end
else
	points1 = d.points2;	% inhale
	points2 = d.points1;	% exhale
	d.moving_points = points1;
	d.fixed_points = points2;
	for i=1:3
		points1(:,idxes1(i)) = (points1(:,idxes1(i)) - d.origin2(idxes2(i)))*10 / d.spacing2(idxes2(i)) + 1;
		points2(:,idxes1(i)) = (points2(:,idxes1(i)) - d.origin1(idxes2(i)))*10 / d.spacing1(idxes2(i)) + 1;
	end
end

mv1(:,1) = (interp3(handles.reg.dvf.x,points2(:,1),points2(:,2),points2(:,3)))*d.spacing1(1)/10;
mv1(:,2) = (interp3(handles.reg.dvf.y,points2(:,1),points2(:,2),points2(:,3)))*d.spacing1(2)/10;
mv1(:,3) = (interp3(handles.reg.dvf.z,points2(:,1),points2(:,2),points2(:,3)))*d.spacing1(3)/10;

d.computed_moving_points(:,1) = d.fixed_points(:,1) - mv1(:,1);
d.computed_moving_points(:,2) = d.fixed_points(:,2) - mv1(:,2);
d.computed_moving_points(:,3) = d.fixed_points(:,3) - mv1(:,3);

handles.reg.landmark_data = d;
handles = Logging(handles,'Computing moved landmarks');

guidata(handles.gui_handles.figure1,handles);
setinfotext('Moved land marks are computed.');

