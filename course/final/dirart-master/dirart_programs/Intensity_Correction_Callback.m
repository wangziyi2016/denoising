function handles = Intensity_Correction_Callback(handles)
%
%
%
f = intensity_correction(handles.images(1).image);
f = f / max(f(:));

handles.images(1).image = handles.images(1).image .* f;

if ~isequal(size(handles.images(1).image),size(handles.images(2).image))
	f = intensity_correction(handles.images(2).image);
	f = f / max(f(:));
end
handles.images(2).image = handles.images(2).image .* f;

