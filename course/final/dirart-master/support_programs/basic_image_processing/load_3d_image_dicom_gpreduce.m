function [im3d,zs,instances] = load_3d_image_dicom_gpreduce(filenamefilter)

n=1;
curdir = pwd;
pathname = curdir;
filename = [];
instances = [];

if ~exist('filenamefilter','var')
	filenamefilter = [];
end

if isempty(filenamefilter)
	while 1
		cd(pathname);
		if isempty(filename)
			[filename, pathname] = uigetfile({'*.IMA;*.dcm','DICOM image files';'*.*','All files (*.*)'},...
				sprintf('Loading images'), 'MultiSelect', 'on');
		else
			filename = sortn(filename);
			[filename, pathname] = uigetfile({'*.IMA;*.dcm','DICOM image files';'*.*','All files (*.*)'},...
				sprintf('Loading images, last file was %s',filename{end}), 'MultiSelect', 'on');
		end

		cd(curdir);

		if( length(filename) == 1 & filename == 0 )
			break;
		end

		H = waitbar(0,'Loading ...');
		for k = 1:length(filename)
			waitbar((k-1)/length(filename),H,sprintf('Loading %s ...',filename{k}));
			info = dicominfo([pathname,filename{k}]);
			position(:,n) = info.ImagePositionPatient;
			instances = [instances info.InstanceNumber];
			temp1 = dicomread([pathname,filename{k}]);
			im3d2(:,:,n) = GPReduce(temp1);
			n = n+1;
		end
		close(H);
	end
else
	filename = dir(filenamefilter);
	pathstr = fileparts(filenamefilter);
	if length(pathstr) > 0
		pathstr = [pathstr filesep];
	end
	
	H = waitbar(0,'Loading ...');
	for k = 1:length(filename)
		waitbar((k-1)/length(filename),H,sprintf('Loading %s ...',filename(k).name));
		info = dicominfo([pathstr filename(k).name]);
		position(:,n) = info.ImagePositionPatient;
		instances = [instances info.InstanceNumber];
		temp1 = dicomread([pathstr filename(k).name]);
		im3d2(:,:,n) = GPReduce(temp1);
		n = n+1;
	end
	close(H);
end

pos1 = position(3,:);
[pos2,idx] = sort(pos1,'ascend');

[pos3,idx3] = sort(instances);

im3d = im3d2(:,:,idx);
zs = pos2;

%im3d = im3d2(:,:,idx3);
instances = instances(idx3);


