function [info,ys,xs,zs] = images_info_dicom(filenamefilter)
% Read dicom images information, including dicom info, x, y and z valus
% [info,ys,xs,zs] = images_info_dicom(filenamefilter)
%
n=1;
curdir = pwd;

filename = dir(filenamefilter);
pathstr = fileparts(filenamefilter);
if length(pathstr) > 0
	pathstr = [pathstr filesep];
end

%fprintf('\n');

for k = 1:length(filename)
	fprintf('.');
	if isdir([pathstr filename(k).name])
		continue;
	end
	try
		info = dicominfo([pathstr filename(k).name]);
		position(:,n) = info.ImagePositionPatient;
		n = n+1;
	end
end
fprintf('\n');

pos1 = position(3,:);
pos2 = sort(pos1,'ascend');
zs = pos2;
xs = info.ImagePositionPatient(1) + single((1:info.Columns)-1)*info.PixelSpacing(1);
ys = info.ImagePositionPatient(2) + single((1:info.Rows)-1)*info.PixelSpacing(1);


