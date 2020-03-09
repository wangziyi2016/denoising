function Accuracy_Analysis_Callback(handles)
handles = Compute_Moved_Land_Marks_Callback(handles);
d = handles.reg.landmark_data;

mvdiff = (d.computed_moving_points - d.moving_points)*10;
%mvdiff = mvdiff(1:end-4,:);
mvdiff
assignin('base','mvdiff',mvdiff);
mvdiff_pixel = mvdiff;
mvdiff_pixel(:,1) = mvdiff_pixel(:,1)/d.spacing1(1);
mvdiff_pixel(:,2) = mvdiff_pixel(:,2)/d.spacing1(2);
mvdiff_pixel(:,3) = mvdiff_pixel(:,3)/d.spacing1(3);

if handles.reg.Log_Output == 1
	diary on;
end

fprintf('\n\n==================================================\n');
fprintf('Land mark analysis results:\n');
fprintf('==================================================\n');
fprintf('\nError (mm): \n');
fprintf('LR: mean = %d, std = %d\n',  mean(mvdiff(:,1)),std(mvdiff(:,1))); 
fprintf('AP: mean = %d, std = %d\n',  mean(mvdiff(:,2)),std(mvdiff(:,2))); 
fprintf('SI: mean = %d, std = %d\n\n',mean(mvdiff(:,3)),std(mvdiff(:,3))); 

mvdiffabs = abs(mvdiff);
fprintf('Absolte error (mm): \n');
fprintf('LR: mean = %d, std = %d, max = %d\n',mean(mvdiffabs(:,1)),std(mvdiffabs(:,1)),max(mvdiffabs(:,1))); 
fprintf('AP: mean = %d, std = %d, max = %d\n',mean(mvdiffabs(:,2)),std(mvdiffabs(:,2)),max(mvdiffabs(:,2))); 
fprintf('SI: mean = %d, std = %d, max = %d\n',mean(mvdiffabs(:,3)),std(mvdiffabs(:,3)),max(mvdiffabs(:,3))); 
mvmrs = sqrt(sum(mvdiffabs.^2,2));
figure;bar(mvmrs);
fprintf('3D: mean = %d, std = %d, max = %d\n',mean(mvmrs),std(mvmrs),max(mvmrs)); 

fprintf('\n\nError (pixels): \n');
fprintf('LR: mean = %d, std = %d\n',  mean(mvdiff_pixel(:,1)),std(mvdiff_pixel(:,1))); 
fprintf('AP: mean = %d, std = %d\n',  mean(mvdiff_pixel(:,2)),std(mvdiff_pixel(:,2))); 
fprintf('SI: mean = %d, std = %d\n\n',mean(mvdiff_pixel(:,3)),std(mvdiff_pixel(:,3))); 

mvdiffabs = abs(mvdiff_pixel);
fprintf('Absolte error (pixels): \n');
fprintf('LR: mean = %d, std = %d\n',mean(mvdiffabs(:,1)),std(mvdiffabs(:,1))); 
fprintf('AP: mean = %d, std = %d\n',mean(mvdiffabs(:,2)),std(mvdiffabs(:,2))); 
fprintf('SI: mean = %d, std = %d\n',mean(mvdiffabs(:,3)),std(mvdiffabs(:,3))); 
mvmrs = sqrt(sum(mvdiff_pixel.^2,2));
fprintf('3D: mean = %d, std = %d\n',mean(mvmrs),std(mvmrs)); 
fprintf('\n\n\n');

if handles.reg.Log_Output == 1
	diary off;
end

