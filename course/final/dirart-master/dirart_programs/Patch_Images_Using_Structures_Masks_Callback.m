function Patch_Images_Using_Structures_Masks_Callback(handles)
%
%	Patch_Images_Using_Structures_Masks_Callback(handles)
%
% Patch image 1 and image 2 images in the structure masks
% Patch prostate, bladder and rectum with different image intensity so that
% these structures can be easily registered

if isempty(handles.images(1).structure_mask) || isempty(handles.images(2).structure_mask)
	return;
end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo
processed_images = handles.images;

prostate_intensity = 1300;
% prostate_intensity = 1100;
bladder_intensity = 800;
% rectum_intensity = 1050;
% rectum_intensity = 500;
rectum_intensity = 800;

structure_masks_1 = handles.images(1).structure_mask;
structure_masks_2 = handles.images(2).structure_mask;

if isfield(handles.reg,'expanded_structure_masks') && ~isempty(handles.reg.expanded_structure_masks)
	structure_masks_1 = handles.reg.expanded_structure_masks;
end

pmask1 = bitget(structure_masks_1,3);
pmask2 = bitget(structure_masks_2,3);

rmask1 = bitget(structure_masks_1,2);
rmask2 = bitget(structure_masks_2,2);

rm1z = squeeze(max(max(rmask1,[],1),[],2));
rm2z = squeeze(max(max(rmask2,[],1),[],2));

minz1 = max(find(rm1z>0,1,'first'),find(rm2z>0,1,'first')+handles.reg.images_setting.image_offsets(3));
maxz1 = min(find(rm1z>0,1,'last'),find(rm2z>0,1,'last')+handles.reg.images_setting.image_offsets(3));
minz2 = minz1 - handles.reg.images_setting.image_offsets(3);
maxz2 = maxz1 - handles.reg.images_setting.image_offsets(3);

rmask1b = rmask1*0;
rmask1b(:,:,minz1:maxz1) = rmask1(:,:,minz1:maxz1);
rmask2b = rmask2*0;
rmask2b(:,:,minz2:maxz2) = rmask2(:,:,minz2:maxz2);

structure_masks_1 = bitset(structure_masks_1,2,rmask1b);
structure_masks_2 = bitset(structure_masks_2,2,rmask2b);


setinfotext('Patching image #1');
img = handles.images(1).image;

Button=questdlg('Patch bladder for image 1?', 'Patch bladder for image 1','Yes','No','Yes');
if strcmp(Button,'Yes') == 1
	mask = bitget(structure_masks_1,1);
	bladder_mean = mean(img(mask==1));
	img(mask==1) = img(mask==1) - bladder_mean + bladder_intensity;
end

Button=questdlg('Patch rectum for image 1?', 'Patch rectum for image 1','Yes','Yes - 1050','No','Yes');
if strcmp(Button,'No') ~= 1
	mask = bitget(structure_masks_1,2);
	if strcmp(Button,'Yes - 1050') == 1
		img(mask==1) = 1050;
	else
		img(mask==1) = rectum_intensity;
	end
end
Button=questdlg('Patch prostate for image 1?', 'Patch prostate for image 1','Yes','No','Use image 2 prostate contour','Yes');
if strcmp(Button,'No') ~= 1
	mask = bitget(structure_masks_1,3);
	prostate_mean = mean(img(mask==1));
	if strcmp(Button,'Yes') ~= 1
		mask = bitget(structure_masks_2,3);
	end
	img(mask==1) = img(mask==1) - prostate_mean + prostate_intensity;
end

handles.images(1).image = img;

setinfotext('Patching image #2');
img = handles.images(2).image;

Button=questdlg('Patch bladder for image 2?', 'Patch bladder for image 2','Yes','No','Yes');
if strcmp(Button,'Yes') == 1
	mask = bitget(structure_masks_2,1);
	bladder_mean = mean(img(mask==1));
	img(mask==1) = img(mask==1) - bladder_mean + bladder_intensity;
end
Button=questdlg('Patch rectum for image 2?', 'Patch rectum for image 2','Yes','Yes - 1050','No','Yes');
if strcmp(Button,'No') ~= 1
	mask = bitget(structure_masks_2,2);
	if strcmp(Button,'Yes - 1050') == 1
		img(mask==1) = 1050;
	else
		img(mask==1) = rectum_intensity;
	end
end

Button=questdlg('Patch prostate for image 2?', 'Patch prostate for image 2','Yes','No','Use image 1 prostate contour','Yes');
if strcmp(Button,'No') ~= 1
	mask = bitget(structure_masks_2,3);
	prostate_mean = mean(img(mask==1));
	if strcmp(Button,'Yes') ~= 1
		mask = bitget(structure_masks_1,3);
	end
	img(mask==1) = img(mask==1) - prostate_mean + prostate_intensity;
end

handles.images(2).image = img;


% highlighting the prostate markers
avg_prostate_intensity = mean(processed_images(1).image(pmask1>0));
prostate_marker_mask = pmask1 & processed_images(1).image > avg_prostate_intensity+200;
handles.images(1).image(prostate_marker_mask>0) = prostate_intensity+300;
avg_prostate_intensity = mean(processed_images(2).image(pmask2>0));
prostate_marker_mask = pmask2 & processed_images(2).image > avg_prostate_intensity+200;
handles.images(2).image(prostate_marker_mask>0) = prostate_intensity+300;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

