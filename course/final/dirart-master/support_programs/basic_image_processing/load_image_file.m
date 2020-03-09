function [img,format,maxvalue] = load_image_file(filename,normalize,format)

if( ~exist('normalize','var') )
	normalize = 0;
end

[pname,name,ext,varname] = fileparts(filename);

try
	if( ~exist('format','var') )
		if( strcmp(ext,'.ima') )
			%img = load_ima(filename);
			img = imaread(filename);
			format = 'ima';
		elseif( strcmp(ext,'.IMA') )
			img = dicomread(filename);
			format = 'dcm';
		elseif( strcmpi(ext,'.dcm') )
			img = dicomread(filename);
			format = 'dcm';
		else
			img = imread(filename);
			format = ext(2:end);
		end
	else
		if( strcmp(format,'ima') )
			%img = load_ima(filename);
			img = imaread(filename);
			format = 'ima';
		elseif( strcmpi(format,'dcm') )
			img = dicomread(filename);
			format = 'dcm';
		else
			img = imread(filename);
			format = ext(2:end);
		end
	end
catch
	ButtonName = questdlg('Image file format cannot be detected successfully, please select the image file format:','Image format selection','Siemens IMA file','DICOM file','DICOM file');
	try
		if( strcmp(ButtonName,'Siemens IMA file') )
			img = imaread(filename);
			format = 'ima';
		elseif( strcmp(ButtonName,'DICOM file') )
			img = dicomread(filename);
			format = 'dcm';
		end
	catch
		error(sprintf('Unknown image file format for file: %s',filename));
	end
end

if( length(size(img)) == 3 )
	img = mean(img,3);
end

maxvalue = max(img(:));
if normalize == 1
	img = single(img);
	maxvalue = single(maxvalue);
	img = img / single(maxvalue);
end

nfilename = filename;

