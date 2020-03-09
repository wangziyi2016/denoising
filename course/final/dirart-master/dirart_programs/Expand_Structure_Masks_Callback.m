function Expand_Structure_Masks_Callback(handles)
%
%
%
% hObject    handle to Expand_Structure_Masks_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = ['Enter number of voxels to expand to structure masks'];
name=sprintf('Expanding Structure Masks');
numlines=1;
if isfield(handles.reg,'expanded_structure_masks')
	defaultanswer={'0'};
else
	defaultanswer={'2'};
end
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	setinfotext('Structure mask expansion is cancelled.');
	return;
end

inputvalues = str2num(answer{1});
% if more than 1 values are input, the first value is the number of voxels
% to expand, the second value is the image intensity threshold values that
% the structure masks should not expanded

if length(inputvalues) > 1
	intensity_threshold = inputvalues(2);
	image1mask = handles.images(1).image < intensity_threshold;
	image1mask = image1mask | handles.images(1).structure_mask ~= 0;
else
	image1mask = ones(mysize(handles.images(1).image));
end

disksize = inputvalues(1);
disksize = max(disksize,0);
disksize = min(disksize,30);
setinfotext(sprintf('Structure mask expansion, disk size = %g',disksize));

if disksize <= 0 && ~isfield(handles.reg,'expanded_structure_masks')
	setinfotext('Structure mask expansion is cancelled.');
	return;
end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo
handles.images(1).structure_mask = uint32(handles.images(1).structure_mask);

if disksize > 0
	masks_out = handles.images(1).structure_mask*0;

	N = floor(log2(max(single(handles.images(1).structure_mask(:)))))+1;
	se = strel('arbitrary',ones(disksize,disksize,disksize));

	masks_out = zeros(mysize(handles.images(1).structure_mask),'uint32');
	for k = N:-1:1
		maskbit = bitget(handles.images(1).structure_mask,k);
		temp_masks_out = imdilate(maskbit,se);
		temp_masks_out = temp_masks_out & ~(handles.images(1).structure_mask ~= 0 & handles.images(1).structure_mask ~= bitshift(maskbit,k-1)) & masks_out == 0;
		temp_masks_out = uint32(temp_masks_out);

		% 		if k == 1
		% 			masks_out=temp_masks_out;
		% 		else
		masks_out = bitor(masks_out,bitshift(temp_masks_out,k-1));
		% 		end
	end

	handles.reg.expanded_structure_masks = masks_out.*uint32(image1mask);
	handles = Logging(handles,'Structure masks are expanded by disk size = %g',disksize);
	setinfotext('Structure masks are expanded.');
else
	handles = rmfield_from_struct(handles.reg,'expanded_structure_masks');
	handles = Logging(handles,'Expanded structure masks are removed');
	setinfotext('Expanded structure masks are removed.');
end

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);
