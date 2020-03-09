function Smooth_Motion_Field_Callback(handles)
%
%	Smooth_Motion_Field_Callback(handles)
%
dvfno = which_DVF_to_process(handles,'Which DVF to smooth ?','DVF Smoothing');
if dvfno == 0
	return;
end


prompt={sprintf('please enter the Gaussian window size (in mm)\n\nIn Y (A-P) direction'),'In X (L-R) direction','In Z (S-I) direction'};
name='Smoothing DVF';
numlines=1;
defaultanswer={'2','2','2'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	disp('Motion field smoothing is cancelled');
else
	kernelsize = [str2double(answer{1}) str2double(answer{2}) str2double(answer{3})];
	if dvfno == 1
		kernelsize = kernelsize./handles.reg.dvf.info.voxelsize;
		handles.reg.dvf.y = lowpass3d(handles.reg.dvf.y,kernelsize);
		handles.reg.dvf.x = lowpass3d(handles.reg.dvf.x,kernelsize);
		handles.reg.dvf.z = lowpass3d(handles.reg.dvf.z,kernelsize);
	else
		kernelsize = kernelsize./handles.reg.idvf.info.voxelsize;
		handles.reg.idvf.y = lowpass3d(handles.reg.idvf.y,kernelsize);
		handles.reg.idvf.x = lowpass3d(handles.reg.idvf.x,kernelsize);
		handles.reg.idvf.z = lowpass3d(handles.reg.idvf.z,kernelsize);
	end
	handles = Logging(handles,'Motion fields are smoothed using kernel size = [%s]', num2str(kernelsize,'%g '));
	guidata(handles.gui_handles.figure1,handles);
	disp('Motion field is smoothed');
end
