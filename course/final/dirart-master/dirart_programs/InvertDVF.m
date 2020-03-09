function handles = InvertDVF(handles,whichdvf)
%
%	handles = InvertDVF(handles,whichdvf)
%
%	whichdvf =	1,	to compute idvf from dvf
%				2,	to compute dvf from idvf
%

if whichdvf == 1
	dvf = handles.reg.dvf;
else
	dvf = handles.reg.idvf;
end

if isempty(dvf.x)
	setinfotext('Warning: no DVF to invert');
	return;
end

answer = questdlg('Generate the inverse DVF in the same dimension as the current DVF ?','DVF inversion','Yes','No','Cancel','Yes');
if strcmpi(answer,'Cancel') == 1
	setinfotext('Warning: DVF inversion is cancelled');
	return;
elseif strcmpi(answer,'Yes') == 1
	[imvy,imvx,imvz,offsets,mask]= invert_motion_field_smart(dvf.y,dvf.x,dvf.z,1);
else
	[imvy,imvx,imvz,offsets,mask]= invert_motion_field_smart(dvf.y,dvf.x,dvf.z);
end

imvy(mask==0) = nan;
imvx(mask==0) = nan;
imvz(mask==0) = nan;

idvf = dvf;
idvf.x = imvx;
idvf.y = imvy;
idvf.z = imvz;
idvf.info.origin = idvf.info.origin - offsets .* idvf.info.voxelsize .* idvf.info.voxel_spacing_dir;

[x,y,z] = TranslateCoordinates(handles,3-whichdvf,idvf.info.origin(2),idvf.info.origin(1),idvf.info.origin(3));
idvf.info.origin = [y x z];

if whichdvf == 1
	handles.reg.idvf = idvf;
else
	handles.reg.dvf = idvf;
end



