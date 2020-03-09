function print_stack(stack)
%
%
%
N = length(stack);
for k = 1:N
% 	fprintf('%d: File [%s] - line [%d] - function [%s]\n',k,stack(k).file,stack(k).line,stack(k).name);
	fprintf('%d: line [%d] - function [%s]\n',k,stack(k).line,stack(k).name);
end
