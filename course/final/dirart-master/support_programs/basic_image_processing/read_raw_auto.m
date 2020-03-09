function im = read_raw_auto(filename)

fid=fopen(filename,'r','ieee-be');
words=fread(fid,5,'uint32');
if words(1) == hex2dec('46474D49')
	fclose(fid);
	fid=fopen(filename,'r','ieee-le');
	words=fread(fid,5,'uint32');
end

if words(1) ~= hex2dec('494D4746')
	error(1,'File format not supported');
end

%fprintf('%X\n',words);
magic = words(1);
header_len = words(2);
width = words(3);
height = words(4);
depth = words(5);

fseek(fid,header_len,'bof');
if depth == 16
	im = fread(fid,width*height,'uint16');
elseif depth == 8
	im = fread(fid,width*height,'uint8');	
elseif depth == 32
	im = fread(fid,width*height,'uint32');	
end
fclose(fid);

im = reshape(im,[width,height]);
im = im';


%im=fread(fid,prod(dim),datatype);
%im = reshape(im,dim);
