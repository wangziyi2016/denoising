function [filename1 pathname1]= SaveMAT2file(prompt,varargin)
% filename = SaveMAT2file(mat)
%

if length(varargin) == 1
	varname = inputname(2);
	eval([varname '=varargin{1};']);
else
	for k=1:nargin-1
		varname{k} = inputname(k+1);
		if isempty(varname{k})
			varname{k} = sprintf('var%d',k);
		end

		eval(['res.' varname{k} '=varargin{' num2str(k) '};']);
	end
end

[filename1, pathname1] = uiputfile({'*.mat'}, prompt);	% Load a 3D image in MATLAB *.mat file
if filename1 ~= 0
	filename = [pathname1 filename1];
	
	if exist(filename,'file')
		fid = fopen(filename,'r');
		fclose(fid);
% 		disp('open and close file');
	end
	pause(0.5);
	
	if length(varargin) == 1
		save(filename,varname);
	else
		save(filename,'-struct','res');
	end
end




