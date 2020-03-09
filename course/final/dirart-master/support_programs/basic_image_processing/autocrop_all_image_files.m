function autocrop_all_image_files(file_spec,outputfile_prefix)
%
% autocrop_all_image_files(file_spec,outputfile_prefix)
% 
% For example: autocrop_all_image_files('*.png','cropped_');
%

if ~exist('file_spec','var') || isempty(file_spec)
	file_spec = '*.png';
end

files = dir(file_spec);

if isempty(files)
	return;
end


for k = 1:length(files)
	file = files(k).name	;
	disp(sprintf('Cropping file: %s',file));
% 	autocrop_2d_color(file,[],[outputfile_prefix file]);
% 	autocrop_2d_color(file,[248 252 248],[outputfile_prefix file]);
	autocrop_2d_color(file,[240 240 240],[outputfile_prefix file]);
end

