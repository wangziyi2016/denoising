function namelist = ListStructureNames(cerr_structures)
%
%	namelist = ListStructureNames(cerr_structures)
%
N = length(cerr_structures);
namelist = cell(N,1);

for k = 1:N
	if iscell(cerr_structures)
		if isempty(cerr_structures{k})
			namelist{k} = '';
		else
			namelist{k} = cerr_structures{k}.structureName;
		end
	else
		if isempty(cerr_structures(k))
			namelist{k} = '';
		else
			namelist{k} = cerr_structures(k).structureName;
		end
	end
end
