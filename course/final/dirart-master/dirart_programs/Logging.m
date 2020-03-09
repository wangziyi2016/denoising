% --------------------------------------------------------------------
function handles = Logging(handles,varargin)
if ~isfield(handles,'log') || isempty(handles.info.log)
	% The first log
	handles.info.log(1) = {datestr(now)};
end

str = sprintf(varargin{:});
if isempty(findstr(str,'Update image offsets manually from keyboard'))
	handles.info.log(end+1,1) = {str};
else
	handles.info.log(end,1) = {str};
end
return;

