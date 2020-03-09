function Ground_Truth_Analysis_Callback(handles)
%
%   Ground_Truth_Analysis_Callback(handles)
%

setinfotext('Loading motion field ...');
[filename, pathname] = uigetfile({'*.mat'}, 'Select a MATLAB file');
if filename == 0
	setinfotext('Cancelled');
	return;
end

mvs = load([pathname filename],'mvx','mvy','mvz','mask');
if ~isfield(mvs,'mvx') || ~isfield(mvs,'mvy') || ~isfield(mvs,'mvz')
	setinfotext('ERROR: Motion field is not available in the file');
	return;
end

mvx = mvs.mvx;
mvy = mvs.mvy;
mvz = mvs.mvz;

mask = ~isnan(handles.images(2).image) .* ~isnan(handles.images(1).image);

Ground_Truth_Analysis(mvy,mvx,mvz,handles.reg.dvf.y,handles.reg.dvf.x,handles.reg.dvf.z,handles.images(1).voxelsize,mask);

