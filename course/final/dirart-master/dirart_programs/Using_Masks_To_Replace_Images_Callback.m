function Using_Masks_To_Replace_Images_Callback(handles)
%
%	Using_Masks_To_Replace_Images_Callback(handles)
%
if isempty(handles.images(1).structure_mask) || isempty(handles.images(2).structure_mask)
	return;
end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

processed_images = handles.images;

pmask1 = bitget(handles.images(1).structure_mask,3);
pmask2 = bitget(handles.images(2).structure_mask,3);

rmask1 = bitget(handles.images(1).structure_mask,2);
rmask2 = bitget(handles.images(2).structure_mask,2);

rm1z = squeeze(max(max(rmask1,[],1),[],2));
rm2z = squeeze(max(max(rmask2,[],1),[],2));

minz1 = max(find(rm1z>0,1,'first'),find(rm2z>0,1,'first')+handles.reg.images_setting.image_offsets(3));
maxz1 = min(find(rm1z>0,1,'last'),find(rm2z>0,1,'last')+handles.reg.images_setting.image_offsets(3));
minz2 = minz1 - handles.reg.images_setting.image_offsets(3);
maxz2 = maxz1 - handles.reg.images_setting.image_offsets(3);

structure_masks_1 = handles.images(1).structure_mask;
structure_masks_2 = handles.images(2).structure_mask;

rmask1b = rmask1*0;
rmask1b(:,:,minz1:maxz1) = rmask1(:,:,minz1:maxz1);
rmask2b = rmask2*0;
rmask2b(:,:,minz2:maxz2) = rmask2(:,:,minz2:maxz2);

structure_masks_1 = bitset(structure_masks_1,2,rmask1b);
structure_masks_2 = bitset(structure_masks_2,2,rmask2b);

setinfotext('Using masks to replace image #1');
handles = Logging(handles,'Using structure masks 1 to replace image 1');
handles.images(1).image = single(structure_masks_1);
% handles.images(1).image(img1>1100) = 3;

% highlighting the prostate markers
avg_prostate_intensity = mean(processed_images(1).image(pmask1>0));
prostate_marker_mask = pmask1 & processed_images(1).image > avg_prostate_intensity+200;
handles.images(1).image(prostate_marker_mask>0) = 5;

setinfotext('Using masks to replace image #2');
handles = Logging(handles,'Using structure masks 2 to replace image 2');
% 	mask_p = bitget(handles.images(2).structure_mask,1);
% 	mask_b = bitget(handles.images(2).structure_mask,2);
% 	mask_r = bitget(handles.images(2).structure_mask,3);
% 	masks = bitor(bitor(mask_b,bitshift(mask_r,1)),bitshift(mask_p,2));
% 	handles.images(2).image = single(masks);
handles.images(2).image = single(structure_masks_2);
% handles.images(2).image(img2>1100) = 3;

% highlighting the prostate markers
avg_prostate_intensity = mean(processed_images(2).image(pmask2>0));
prostate_marker_mask = pmask2 & processed_images(2).image > avg_prostate_intensity+200;
handles.images(2).image(prostate_marker_mask>0) = 5;

handles.images(1).image = single(bitget(structure_masks_1,1));	% bladder only
handles.images(2).image = single(bitget(structure_masks_2,1));	% bladder only

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);


