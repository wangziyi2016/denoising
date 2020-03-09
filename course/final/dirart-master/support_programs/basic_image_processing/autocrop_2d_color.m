function varargout = autocrop_2d_color(infile,val,outfilename)
%
% imout = autocrop_2d_color(infilename,val,outfilename);
% imout = autocrop_2d_color(imin,val);
%
if ~exist('val','var') || isempty(val)
	val = [255 255 255];
end

if ischar(infile)
	infilename = infile;
	if ~exist('outfilename','var')
		[pathstr,name,ext,versn] = fileparts(infilename);
		outfilename = fullfile(pathstr,[name '_cropped' ext]);
	end

	if ~exist(infilename,'file')
		error(sprintf('File %s does not exist.',infilename));
	end
	im = imread(infilename);
	info = imfinfo(infilename);
else
	im = infile;
end

for k = 1:size(im,3)
	c(:,:,k) = single(im(:,:,k)>=val(k));
end

mask = sum(c,3);
mask = (mask == size(im,3));

% boundary = 2;
% mask([1:boundary end-boundary:end],:)=1;
% mask(:,[1:boundary end-boundary:end])=1;

mask2a=mean(mask,1);
x1=find(mask2a~=1,1);
x2=find(mask2a~=1,1,'last');

mask2b=mean(mask,2);
y1=find(mask2b~=1,1);
y2=find(mask2b~=1,1,'last');

imout=im(y1:y2,x1:x2,:);
%imout = im(100:249,45:199,:);

if exist('outfilename','var')
	if exist('info','var') && isfield(info,'XResolution')
		res = info.XResolution;
	else
		res = 300;
	end
	
	if res == 0
		res = 300;
	end
	
	imwrite(imout,outfilename,'Resolution',300);
% 	imwrite(imout,outfilename,'Resolution',res);
	disp(sprintf('Out to %s',outfilename));
end

if nargout > 0
	varargout{1} = imout;
end


% 
% 
% figure;
% subplot(121);
% imshow(im);
% subplot(122);
% imshow(imout);
