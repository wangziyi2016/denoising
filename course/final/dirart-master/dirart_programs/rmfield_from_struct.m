function structout = rmfield_from_struct(structin,fnamesin)
%
%	structout = rmfield_from_struct(structin,fnamesin)
%
if ~iscell(fnamesin)
	fnames{1} = fnamesin;
else
	fnames = fnamesin;
end

N = length(fnames);
structout = structin;
for k =1:N
	name = fnames{k};
	if isfield(structout,name)
		structout = rmfield(structout,name);
	end
end

