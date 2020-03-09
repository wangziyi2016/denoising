function dosestrs = GenerateDoseDescriptionList(doses)
%
%	dosestrs = GenerateDoseDescriptionList(doses)
%
N = length(doses);
dosestrs = [];
for k =1:N
	dose = doses{k};
	if ~isfield(dose,'Description')
		des = '';
		doses{k}.Description = '';
	else
		des = dose.Description;
	end

	dosestrs{k} = sprintf('%d - %s',k,des);
end

