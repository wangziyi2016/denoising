function [img,nfilename,format,maxvalue] = load_image(filename,prompt,normalize)

if ~exist('prompt','var') || isempty(prompt)
	prompt = 'Load image...';
end

if ~exist('normalize','var') || isempty(normalize)
	normalize = 1;
end

if( ~exist('filename','var') || isempty(filename) )
	[filename, pathname] = uigetfile({'*.jpg;*.gif;*.png;*.ima;*.IMA;*.dcm','All image files';'*.jpg;*.gif;*.png','General image files (*.jpg;*.gif;*.png)';'*.ima','IMA files (*.ima)';'*.dcm;*.IMA','DICOM files (*.dcm;*.IMA)';'*.*','All files (*.*)'}, prompt);

	if( filename == 0 )
		img = [];
		return;
	end
	
	filename = [pathname,filename];
end

[img,format,maxvalue] = load_image_file(filename,normalize);

nfilename = filename;

