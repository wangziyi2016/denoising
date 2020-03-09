function data = GetElement(array,no)
%
%	data = GetElement(array,no)
%
if iscell(array)
	data = array{no};
else
	data = array(no);
end
