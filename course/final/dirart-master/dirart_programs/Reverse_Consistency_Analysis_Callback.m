function handles = Reverse_Consistency_Analysis_Callback(handles)
%
%	handles = Reverse_Consistency_Analysis_Callback(handles)
%
if isempty(handles.reg.idvf.x)
	return;
% 	setinfotext('Loading reverse motion field ...');
% 	[filename, pathname] = uigetfile({'*.mat'}, 'Select a MATLAB file');
% 	if filename == 0
% 		setinfotext('Cancelled');
% 		return;
% 	end
% 
% 	rmvs = load([pathname filename],'mvx','mvy','mvz');
% 	if ~isfield(rmvs,'mvx') || ~isfield(rmvs,'mvy')  || ~isfield(rmvs,'mvz')
% 		setinfotext('ERROR: Motion field is not available in the file');
% 		return;
% 	end
% 
% 	if ~isequal(size(rmvs.mvx),size(handles.reg.dvf.x))
% 		setinfotext('ERROR: Motion field matrix dimension mismatch');
% 		return;
% 	end
% 	
% 	handles.reg.idvf.x = rmvs.mvx;
% 	handles.reg.idvf.y = rmvs.mvy;
% 	handles.reg.idvf.z = rmvs.mvz;
% 	
% 	guidata(handles.gui_handles.figure1,handles);
end

erx = handles.reg.dvf.x + move3dimage(handles.reg.idvf.x,handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z);
ery = handles.reg.dvf.y + move3dimage(handles.reg.idvf.y,handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z);
erz = handles.reg.dvf.z + move3dimage(handles.reg.idvf.z,handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z);
ers = sqrt(erx.^2+ery.^2+erz.^2);
handles.reg.inverse_consistency_errors = ers;
guidata(handles.gui_handles.figure1,handles);
ers2 = ers(~isnan(ers(:)));

if handles.reg.Log_Output == 1
	diary on;
end

fprintf('\n\n==================================================\n');
fprintf('Reverse consistency analysis results:\n');
fprintf('==================================================\n');
fprintf('Mean = %d, std = %d\n',mean(ers2(:)),std(ers2(:)));
fprintf('Median = %d, max = %d\n',median(ers2(:)),max(ers2(:)));

ers = ers(4:end-3,4:end-3,:);
ers2 = ers(~isnan(ers(:)));
fprintf('WO boundary: Mean = %d, std = %d\n',mean(ers2(:)),std(ers2(:)));
fprintf('WO boundary: Median = %d, max = %d\n',median(ers2(:)),max(ers2(:)));

[n,xout] = hist(ers2(:),50);
figure;bar(xout,log10(n));
xlabel('Inverse consistency error (pixel)')
ylabel('Pixel count (log10)');
if ndims(ers) == 2
	figure;imagesc(ers);colorbar;axis off;axis image;
	if Check_MenuItem(handles.gui_handles.Options_Show_Pixel_Information_Menu_Item,0) == 1
		impixelinfo;
	end
else
	ratio = handles.images(1).voxelsize/min(handles.images(1).voxelsize);
	view3dgui(ers,ratio);
end

if handles.reg.Log_Output == 1
	diary off;
end

