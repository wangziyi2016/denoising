function varargout = interp1wrapper(x,y,varargin)
%
% varargout = interp1wrapper(x,y,varargin)
%	
% This function will double check x, to make sure it increases
%
x = MakeRowVector(x);
y = MakeRowVector(y);
if x(2)<x(1)
	x = fliplr(x);
	y = fliplr(y);
end

varargout{:} = interp1(x,y,varargin{:});
