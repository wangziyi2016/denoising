function association = GetAssociatedImageIdx(handles,assocScanUID)
%
% association = GetAssociatedImageIdx(handles,assocScanUID)
% association = GetAssociatedImageIdx(handles)
%
if exist('assocScanUID','var')
	association = FindMatchingImageUID(handles,assocScanUID);
	if association > 0
		return;
	end
end

button = questdlg('Is it associated with or computed on ?','Dose / Image association','Moving Image','Fixed Image','Moving Image');
association = 1;
if strcmpi(button,'fixed image')
	association = 2;
end

