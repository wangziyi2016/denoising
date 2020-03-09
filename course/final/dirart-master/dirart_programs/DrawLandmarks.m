function DrawLandmarks(handles,idx)
%
%
%
% Draw land marks
% draw_land_marks = Check_MenuItem(handles.gui_handles.Option_Show_Land_Marks_Menu_Item,0);
draw_land_marks = handles.gui_options.display_landmarks(idx);
if isfield(handles.reg,'landmark_data') && draw_land_marks == 1
	hold on;
	
% 	displaymode = handles.gui_options.display_mode(idx,2);
	viewdir = handles.gui_options.display_mode(idx,1);
	slidervalues = GetSliderValues(handles,2);

	
	dat = handles.reg.landmark_data;
	if isempty(findstr(lower(handles.images(1).filename),'inhale'))
		% Using exhale points
		points1 = dat.points1;
		points2 = dat.points2;
	else
		% Using inhale points
		points1 = dat.points2;
		points2 = dat.points1;
	end

	for P = 1:3
		if P == 1
			points = points1;
		elseif P == 2
			points = points2;
		elseif P == 3
			if ~isfield(dat,'computed_moving_points')
				continue;
			else
				points = dat.computed_moving_points;
			end
		end

		% convert to image pixels
		points(:,1) = (points(:,1) - dat.origin1(2))*10 / dat.spacing1(2) + 1;
		points(:,2) = (points(:,2) - dat.origin1(1))*10 / dat.spacing1(1) + 1;
		points(:,3) = (points(:,3) - dat.origin1(3))*10 / dat.spacing1(3) + 1;
		
% 		vvs = GetImageCoordinateVectors(handles,2);
		dim = mysize(handles.images(2).image);
		yoffs = 1:dim(1);
		xoffs = 1:dim(2);
		zoffs = 1:dim(3);

		for k = 1:size(points,1)
			switch viewdir
				case 1	% coronal
					if abs(yoffs(slidervalues(1))-points(k,2)) <= 0.5
						drawcross(points(k,1),points(k,3),k,P);
					end
				case 2	% sagittal
					if abs(xoffs(slidervalues(2))-points(k,1)) <= 0.5
						drawcross(points(k,2),points(k,3),k,P);
					end
				case 3	% transverse
					if abs(zoffs(slidervalues(3))-points(k,3)) <= 0.5
						drawcross(points(k,1),points(k,2),k,P);
					end
			end
		end
	end
end


function drawcross(x,y,num,groupno)
x = double(x);
y = double(y);

if groupno == 1
	c = 'r';
elseif groupno == 2
	c = 'b';
else
	c = 'g';
end

x1=x-3;x2=x+3;y1=y-3;y2=y+3;
XX=[x1 x2];
YY=[y1 y2];
hl=line(XX,YY,'Color',c);
set(hl,'hittest','off');
XX=[x2 x1];
YY=[y1 y2];
hl=line(XX,YY,'Color',c);
set(hl,'hittest','off');
ht=text(round(x+2),round(y),num2str(num));
set(ht,'Color',c,'FontSize',8,'FontUnits','normalized');
set(ht,'hittest','off');
return;


