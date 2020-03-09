function names = PrefixStructureNames(handles)
%
%	names = PrefixStructureNames(handles)
%

names = handles.ART.structure_names;
N = length(handles.ART.structures);
for k = 1:N
	if handles.ART.structure_assocImgIdxes(k) == 1
		names{k} = ['1 - ' names{k}];
	else
		names{k} = ['2 - ' names{k}];
	end
end


