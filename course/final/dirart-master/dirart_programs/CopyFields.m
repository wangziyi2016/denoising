function newStruct = CopyFields(srcStruct,dstStruct,fnames)
%
%	newStruct = CopyFields(srcStruct,dstStruct,fnames)
%
newStruct = dstStruct;
N = length(fnames);
for k = 1:N
	fname = fnames{k};
	if isfield(srcStruct,fname)
		newStruct.(fname) = srcStruct.(fname);
	end
end
