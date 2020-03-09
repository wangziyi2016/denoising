function dicomupdate(filename,newfilename,values)

disp('Reading DICOM image data ...');
img = dicomread(filename);
disp('Reading DICOM meta data ...');
info = dicominfo(filename);

disp('Updating DICOM meta data fields ...');
valuenames = fieldnames(values);
for k = 1:length(valuenames)
	if isfield(info,valuenames{k})
		info.(valuenames{k}) = values.(valuenames{k});
	end
end

disp('Writing DICOM file, please wait ..');
dicomwrite(img,newfilename,info,'CreateMode','copy');

disp('dicomupdate is done');

