function Similarity_Measurement_Callback(handles)
%
%	Similarity_Measurement_Callback(handles)
%

dim2 = mysize(handles.images(2).image);
yoffs = (1:dim2(1))+handles.reg.images_setting.image_current_offsets(1);
xoffs = (1:dim2(2))+handles.reg.images_setting.image_current_offsets(2);
zoffs = (1:dim2(3))+handles.reg.images_setting.image_current_offsets(3);

if isfield(handles.reg.images_setting,'max_intensity_value')
	maxv = handles.reg.images_setting.max_intensity_value;
else
	maxv1 = max(handles.images(1).image(:));
	maxv2 = max(handles.images(2).image(:));
	maxv = max(maxv1,maxv2);
end

if handles.reg.Log_Output == 1
	diary on;
end

fprintf('\n\n==================================================\n');
fprintf('Similarity measurement:\n');
fprintf('==================================================\n');
[MI,CC,entropy,MSE,NMI] = images_info(handles.images(1).image(yoffs,xoffs,zoffs)*maxv,handles.images(2).image * maxv,'MI','CC','entropy','MSE','NMI');
fprintf('Before registration:\nMI = %.5f\nNMI = %.5f\nCC = %.5f\nMSE = %.5g\nEntropy = %.5g\n\n',MI,NMI,CC,MSE,entropy);

if ~isempty(handles.images(1).image_deformed)
	if ~isempty(handles.images(2).image_deformed)
		[MI,CC,entropy,MSE,NMI] = images_info(handles.images(1).image_deformed*maxv,handles.images(2).image_deformed*maxv,'MI','CC','entropy','MSE','NMI');
	else
		[MI,CC,entropy,MSE,NMI] = images_info(handles.images(1).image_deformed(yoffs,xoffs,zoffs)*maxv,handles.images(2).image*maxv,'MI','CC','entropy','MSE','NMI');
	end
	fprintf('After registration:\nMI = %.5f\nNMI = %.5f\nCC = %.5f\nMSE = %.5g\nEntropy = %.5g\n\n',MI,NMI,CC,MSE,entropy);
end

if handles.reg.Log_Output == 1
	diary off;
end


