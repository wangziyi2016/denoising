function filename = SaveMAT2file2(prompt,mat)
% filename = SaveMAT2file2(mat)
% This function will rename the variable according to the user selected
% filename

[filename1, pathname1] = uiputfile({'*.mat'}, prompt);	% Load a 3D image in MATLAB *.mat file
if filename1 ~= 0
	filename = [pathname1 filename1];
	[pathstr, namestr] = fileparts(filename);
	eval([namestr '=mat;']);
	save(filename,namestr);
else
	filename = 0;
end




