function Mark_MVCT_FOV_As_NaN_Callback(handles)
%
%	Mark_MVCT_FOV_As_NaN_Callback(handles)
%

ButtonName=questdlg('Which image is the MVCT ?', 'Which image is the MVCT','1','2','2');

mvctno = str2double(ButtonName);

if mvctno ~= 1 && mvctno ~= 2
	disp('Wrong MVCT number.');
	return;
end

% if size(handles.images(mvctno).image) ~= [512 512]
% 	disp('Wrong MVCT dimension, not [512 512]');
% 	return;
% end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

mask = create_MVCT_FOV_mask(handles.images(mvctno).image);
mask = single(mask);
img = handles.images(mvctno).image;
mask(mask==0)=nan;
for k = 1:size(img,3)
	img(:,:,k) = img(:,:,k).*mask;
end
handles.images(mvctno).image = img;
RefreshDisplay(handles);
guidata(handles.gui_handles.figure1,handles);
