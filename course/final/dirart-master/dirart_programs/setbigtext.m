function setbigtext(msg)
obj = findobj(gcbf, 'Tag', 'bigtext');
if ~isempty(obj)
	set(obj, 'String', msg);
end
return;


