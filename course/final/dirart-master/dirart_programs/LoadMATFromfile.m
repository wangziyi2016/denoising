function [mat,filename] = LoadMATFromfile(prompt)
% mat = LoadMATFromfile(prompt)
%

[filename1, pathname1] = uigetfile({'*.mat'}, prompt);	% Load a 3D image in MATLAB *.mat file
if filename1 == 0
	mat = [];
	filename = [];
	return;
end


filename = [pathname1 filename1];
mat = load(filename);




