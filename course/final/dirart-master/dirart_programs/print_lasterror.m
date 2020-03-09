function print_lasterror(errs)
%
%	print_lasterror()
%	print_lasterror(errs)
%
if ~exist('errs','var')
	errs = lasterror;
end
fprintf('Error happens: %s\n',errs.message);
print_stack(errs.stack);

