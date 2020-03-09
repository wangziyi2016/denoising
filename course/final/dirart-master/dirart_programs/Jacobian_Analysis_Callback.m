function Jacobian_Analysis_Callback(handles)
%
%	Jacobian_Analysis_Callback(handles)
%
dvfno = which_DVF_to_process(handles,'Which DVF to perform Jacobian analysis ?','Jacobian Analysis');
if dvfno == 0
	return;
end

if dvfno == 1
	handles.reg.jacobian = motion_field_jacobian(handles.reg.dvf.x,handles.reg.dvf.y,handles.reg.dvf.z);
else
	handles.reg.jacobian = motion_field_jacobian(handles.reg.idvf.x,handles.reg.idvf.y,handles.reg.idvf.z);
end
guidata(handles.gui_handles.figure1,handles);

% jac = handles.reg.jacobian(handles.images(2).image>0);
jac = handles.reg.jacobian(:);

if handles.reg.Log_Output == 1
	diary on;
end

setinfotext('Jacobian map is computed');
fprintf('\n\n==================================================\n');
fprintf('Jacobian analysis results:\n');
fprintf('==================================================\n');
fprintf('Mean = %d\n',mean(jac(:)));
fprintf('STD = %d\n',std(jac(:)));
fprintf('Median = %d\n',median(jac(:)));
dim = mysize(jac);
c = length(find(jac<=0));
fprintf('Value <= 0: %.2g percent\n', c/prod(dim)*100);
fprintf('\n\n\n');

if ndims(handles.images(1).image) == 2
	figure;imagesc(handles.reg.jacobian,[0.8 1.2]);colorbar;axis off;axis image;
end

if handles.reg.Log_Output == 1
	diary off;
end


