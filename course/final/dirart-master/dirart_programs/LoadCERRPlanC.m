function [planC,filename] = LoadCERRPlanC(filename)
%
%	[planC,filename] = LoadCERRPlanC(filename)
%

planC = [];

if ~exist('filename','var')
	[filename, pathname] = uigetfile({'*.mat'}, 'Select CERR plan');	% Load a 3D image in MATLAB *.mat file
	if filename == 0
		return;
	end

	filename = [pathname,filename];
else
	%Check that file exists.
	if ~(exist(filename, 'file') == 2)
		error(sprintf('File [%s] does not exist',filename));
	end
end

%Check for .bz2 compression and extract .mat file.
[pathstr, name, ext] = fileparts(filename);
if strcmpi(ext, '.bz2')
    bzFile      = 1;
    outstr      = gnuCERRCompression([fullfile(pathstr, name),ext], 'uncompress');
    loadfile    = fullfile(pathstr, name);
    [pathstr, name, ext] = fileparts([fullfile(pathstr, name),ext]);
elseif strcmpi(ext, 'zip')
    bzFile      = 1;
    unzip(file,pathstr)
    loadfile    = fullfile(pathstr, name);
    [pathstr, name, ext] = fileparts([fullfile(pathstr, name),ext]);
else
    bzFile      = 0;
    loadfile    = filename;
end

%Attempt to load the .mat file.
try
    planC = load(loadfile);
    planC = planC.planC;
end

%Remove unzipped file after loading.
if bzFile
    delete(loadfile);
end

if ~exist('planC');
    error('.mat or .mat.bz2 file does not contain a planC variable.');
    return;
end



