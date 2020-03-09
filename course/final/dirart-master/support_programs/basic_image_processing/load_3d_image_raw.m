function img = load_3d_image_raw(filename,dim,data_type,data_align)
%
% load_image_3d_raw(filename,dim,data_type,data_align)
%
% data_type = 'int8', 'int16', 'int32', 'single', 'float', 'double',
% data_align = 'ieee-le','ieee-be'

if nargin < 2
	disp('Usage:');
	disp('img = load_3d_image_raw(filename,dim,data_type=int16,data_align=ieee-le)');
	img = [];
	return;
end

if ~exist(filename,'file')
	error(sprintf('File %s does not exist',filename));
end

if ~exist('data_type','var') || isempty(data_type)
	data_type = 'int16';
end
convertstr = [data_type '=>' data_type];

if ~exist('data_align','var') || isempty(data_align)
	data_align = 'ieee-le';	% Try ieee-le first
	fid = fopen(filename,'r',data_align);
	img = fread(fid,convertstr);
	fclose(fid);
	
	if ~isempty(find((img>70000),1)) || ~isempty(find((img < -4000),1))
		data_align = 'ieee-be';	% If ieee-le is not correct, then try ieee-be
		fid = fopen(filename,'r',data_align);
		img = fread(fid,convertstr);
		fclose(fid);
	end
else
	fid = fopen(filename,'r',data_align);
	img = fread(fid,convertstr);
	fclose(fid);
end

if length(dim) == 1
	dim(2) = dim;
end

if length(dim) == 2
	L = length(img);
	N = L / dim(1) / dim(2);
	dim(3) = N;
	img = reshape(img,dim);
else
	img = reshape(img,dim);
end
img = permute(img,[2 1 3 4]);







