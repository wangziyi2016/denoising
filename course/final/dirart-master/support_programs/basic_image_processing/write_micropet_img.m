function write_micropet_img(img,filename,datatype)

if strcmp(filename(end-2:end),'img') ~= 1
	filename = [filename '.img'];
end

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

img = permute(img,[2 1 3 4]);

switch datatype
	case {1,'int8','1'}
		img = int8(img);
		fid = fopen(filename,'w');
		fwrite(fid,img,'int8=>int8');
	case {2,'int16','2'}
		img = int16(img);
		fid = fopen(filename,'w','ieee-le');
		fwrite(fid,img,'int16');
	case {3,'int32','3'}
		img = int32(img);
		fid = fopen(filename,'w','ieee-le');
		fwrite(fid,img,'int32');
	case {4,'float','single','4'}
		img = single(img);
		fid = fopen(filename,'w','ieee-le');
		fwrite(fid,img,'single');
	case {5,'5'}
		img = single(img);
		fid = fopen(filename,'w','ieee-be');
		fwrite(fid,img,'single');
	case {6,'6'}
		img = int16(img);
		fid = fopen(filename,'w','ieee-be');
		fwrite(fid,img,'int16');
	case {7,'7'}
		img = int32(img);
		fid = fopen(filename,'w','ieee-be');
		fwrite(fid,img,'int32');
	otherwise
		error('Unsupported datatype parameter');
end

fclose(fid);





