function Patch_Images_with_ART_Structure(handles)
%
%	Patch_Images_with_ART_Structure(handles)
%
% Patch image 1 and image 2 using their structure masks

if isempty(handles.ART.structures)
	setinfotext('Not structures to use');
	return;
end

imgstr=questdlg('On which image?','Pathing image with structure mask','Moving image','Fixed image','Moving image');
imgidx = strcmpi(imgstr,'Fixed image')+1;

strnums = find(handles.ART.structure_assocImgIdxes==imgidx);
if isempty(strnums)
	setinfotext(sprintf('There is no structure loaded for the %s',imgstr));
	return;
end

[sel,ok] = listdlg('ListString',handles.ART.structure_names(strnums),'SelectionMode','single','Name','Select a structure');
if ok==0
	setinfotext('Cancelled');
	return;
end

strnum = strnums(sel);

patchmodestr=questdlg('Use constant value or update the mean intensity', sprintf('Patch the %s',imgstr),'Use constant value','Update mean value','Update mean value');
answer=inputdlg('Intensity value to patch:',patchmodestr,1,{'1000'});
if isempty(answer)
	setinfotext('Cancelled');
	return;
end
intensity = str2double(answer{1});

setinfotext(sprintf('Patching structure [%s] in the %s using value = %d',handles.ART.structure_names{strnum},imgstr,intensity));
[mask3d,yVals,xVals,zVals,offs] = MakeStructureMask(handles,strnum,2);

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

img = handles.images(imgidx).image;

dim = size(mask3d);
ys = (1:dim(1))+offs(1);
xs = (1:dim(2))+offs(2);
zs = (1:dim(3))+offs(3);

img2 = img(ys,xs,zs);

if strcmpi(patchmodestr,'Update mean value') == 1
	meanval = mean(img2(mask3d==1));
	img2(mask3d==1) = img2(mask3d==1) - meanval + intensity;
else
	img2(mask3d==1) = intensity;
end

handles.images(imgidx).image(ys,xs,zs) = img2;
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

