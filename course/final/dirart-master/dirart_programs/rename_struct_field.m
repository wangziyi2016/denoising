function structout = rename_struct_field(structin,oldname,newname)
%
%	structout = rename_struct_field(structin,oldname,newname)
%
structout=structin;
if isfield(structin,oldname)
	val = structin.(oldname);
	structout = rmfield(structout,oldname);
	structout.(newname) = val;
end

