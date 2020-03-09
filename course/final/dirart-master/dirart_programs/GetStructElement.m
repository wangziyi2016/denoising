function val = GetStructElement(strdata,fieldname)
%	
%	val = GetStructElement(strdata,fieldname)
%
val = [];
if isfield(strdata,fieldname)
	val = strdata.(fieldname);
end


