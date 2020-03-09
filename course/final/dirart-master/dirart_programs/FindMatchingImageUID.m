function imgidx = FindMatchingImageUID(handles,UID2find)
%
%
%
imgidx = 0;
if isempty(handles.images(1))
	return;
end

for k = 1:2
	if isfield(handles.images(k),'UID') && strcmpi(handles.images(k).UID,UID2find) == 1
		imgidx = k;
		return;
	end
end
