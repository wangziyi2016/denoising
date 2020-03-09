function img = read_micropet_img(filename)

if strcmp(filename(end-2:end),'img') ~= 1
	headerfilename = [filename '.hdr'];
	filename = [filename '.img'];
else
	headerfilename = [filename(1:(end-2)) 'hdr'];
end

if ~exist(filename,'file')
	error(sprintf('File %s does not exist',filename));
end

hdr = get_micropet_img_hdr(headerfilename);

ndim = str2num(hdr.number_of_dimensions);
dim(1) = str2num(hdr.x_dimension);
dim(2) = str2num(hdr.y_dimension);
dim(3) = str2num(hdr.z_dimension);
dim(4) = str2num(hdr.w_dimension);

dim = dim(1:ndim);

% #
% # Data type (integer)
% #   0 - Unknown data type
% #   1 - Byte (8-bits) data type
% #   2 - 2-byte integer - Intel style
% #   3 - 4-byte integer - Intel style
% #   4 - 4-byte float - Intel style
% #   5 - 4-byte float - Sun style
% #   6 - 2-byte integer - Sun style
% #   7 - 4-byte integer - Sun style
% #

switch str2num(hdr.data_type)
	case 1
		fid = fopen(filename,'r');
		img = fread(fid,prod(dim),'int8=>int8');
	case 2
		fid = fopen(filename,'r','ieee-le');
		img = fread(fid,prod(dim),'int16=>int16');
	case 3
		fid = fopen(filename,'r','ieee-le');
		img = fread(fid,prod(dim),'int32=>int32');
	case 4
		fid = fopen(filename,'r','ieee-le');
		img = fread(fid,prod(dim),'single=>single');
	case 5
		fid = fopen(filename,'r','ieee-be');
		img = fread(fid,prod(dim),'single=>single');
	case 6
		fid = fopen(filename,'r','ieee-be');
		img = fread(fid,prod(dim),'int16=>int16');
	case 7
		fid = fopen(filename,'r','ieee-be');
		img = fread(fid,prod(dim),'int32=>int32');
end

fclose(fid);

img = reshape(img,dim);
img = permute(img,[2 1 3 4]);







