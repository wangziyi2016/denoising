function dst = CopyDataStructures(src,dst)
%
%	dst = CopyDataStructures(src,dst)
%
if ~isstruct(dst) || ~isstruct(src)
	if ~isstruct(dst) && ~isstruct(src)
		dst = src;
	end
	return;
end

fnames = fieldnames(dst);
for k = 1:length(fnames)
	fname = fnames{k};
	if ~isfield(src,fname)
		continue;
	end
	
	if iscell(dst.(fname))
		if isempty(dst.(fname))
			dst.(fname) = src.(fname);
		elseif iscell(src.(fname)) && length(dst.(fname)) == length(src.(fname))
			for f = 1:length(dst.(fname))
				dst.(fname){f} = CopyDataStructures(src.(fname){f},dst.(fname){f});
			end
		end
		continue;
	end
	
	if isstruct(dst.(fname))
		if ~isstruct(src.(fname)) || length(dst.(fname)) ~= length(src.(fname))
			continue;
		elseif length(dst.(fname)) > 1
			for f = 1:length(dst.(fname))
				dst.(fname)(f) = CopyDataStructures(src.(fname)(f),dst.(fname)(f));
			end
		else
			dst.(fname) = CopyDataStructures(src.(fname),dst.(fname));
		end
		continue;
	end

	dst.(fname) = src.(fname);
end
