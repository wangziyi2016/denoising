function im3d = load_3d_image(normalize)
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if( ~exist('normalize','var') )
	normalize = 1;
end

n=1;
format = [];
curdir = pwd;
pathname = curdir;

while 1
	cd(pathname);
	[filename, pathname] = uigetfile({'*.jpg;*.gif;*.png;*.ima;*.IMA;*.dcm',...
		'All image files';'*.jpg;*.gif;*.png','General image files (*.jpg;*.gif;*.png)';...
		'*.ima','IMA files (*.ima)';'*.dcm;*.IMA','DICOM files (*.dcm;*.IMA)';'*.*','All files (*.*)'},...
		sprintf('Loading image %d',n), 'MultiSelect', 'on');
	
	cd(curdir);
	
	if( length(filename) == 1 & filename == 0 )
		break;
	end
	
	filename = sortn(filename);
	
	for k = 1:length(filename)
		if isempty(format)
			[im3d(:,:,n),format] = load_image_file([pathname,filename{k}],0);
		else
			[im3d(:,:,n),format] = load_image_file([pathname,filename{k}],0,format);
		end
		n = n+1;
	end
end

if normalize == 1
	im3d = single(im3d);
	maxv = max(im3d(:));
	im3d = im3d / maxv;
end



