
% Bit OR in n direction
function out = bitOpn(in,n,op)
dim = size(in);
switch lower(op)
	case 'and'
		func = @bitand;
	case 'or'
		func = @bitor;
	case 'xor'
		func = @bitxor;
end

switch n
	case 1
		out = zeros(dim(2),dim(3),class(in));
		for k = 1:dim(1)
			out = func(out,squeeze(in(k,:,:)));
		end
	case 2
		out = zeros(dim(1),dim(3),class(in));
		for k = 1:dim(2)
			out = func(out,squeeze(in(:,k,:)));
		end
	case 3
		out = zeros(dim(1),dim(2),class(in));
		for k = 1:dim(3)
			out = func(out,squeeze(in(:,:,k)));
		end
end
return;

