function Change_NaN_Voxels_Callback(handles)
%
%
%

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

prompt={'Val'};
name=sprintf('Please enter the new value');
numlines=1;
defaultanswer={'0'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	disp('Changing nan voxels is cancelled');
	return;
else
	padval = str2num(answer{1});
end

img1 = handles.images(1).image;
img1(isnan(img1)) = padval;
handles.images(1).image = img1;

img1 = handles.images(2).image;
img1(isnan(img1)) = padval;
handles.images(2).image = img1;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

