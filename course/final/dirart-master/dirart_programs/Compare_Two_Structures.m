function Compare_Two_Structures(handles)
%
%	Compare_Two_Structures(handles)
%
[str1,ok] = listdlg('ListString',PrefixStructureNames(handles),'ListSize',[200 300],'Name','Structure Selection',...
	'PromptString','Please select the 1st structure','SelectionMode','single');
if ok == 0
	setinfotext('Structures comparison is cancelled');
	return;
end

[str2,ok] = listdlg('ListString',PrefixStructureNames(handles),'ListSize',[200 300],'Name','Structure Selection',...
	'PromptString','Please select the 2nd structure','SelectionMode','single');
if ok == 0
	setinfotext('Structures comparison is cancelled');
	return;
end

if handles.ART.structure_assocImgIdxes(str1) == handles.ART.structure_assocImgIdxes(str2)
	[mask1,yVals1,xVals1,zVals1] = MakeStructureMask(handles,str1,1);
	[mask2,yVals2,xVals2,zVals2] = MakeStructureMask(handles,str2,1);
	dice_ratio = Compare2Masks(mask1,mask2,3);
	
	voxelsize = handles.images(handles.ART.structure_assocImgIdxes(str1)).voxelsize;
	vol1 = sum(mask1(:))*prod(voxelsize)/1000;
	vol2 = sum(mask2(:))*prod(voxelsize)/1000;
	
	diffmask = abs(mask1-mask2);
	diffvol = sum(diffmask(:))*prod(voxelsize)/1000;
	
	fprintf('Dice similarity ratio for "%s" and "%s" = %.2f\n',handles.ART.structure_names{str1},handles.ART.structure_names{str2},dice_ratio);
	fprintf('Volume of "%s" = %.2f cc\n',handles.ART.structure_names{str1},vol1);
	fprintf('Volume of "%s" = %.2f cc\n',handles.ART.structure_names{str2},vol2);
	fprintf('Volume of difference = %.2f cc\n',diffvol);
end

