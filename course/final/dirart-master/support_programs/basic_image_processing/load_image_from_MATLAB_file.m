function [img,info] = load_image_from_MATLAB_file(filename)
%
% img3d = load_image_from_MATLAB_file(filename)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

data = load(filename);
fnames = fieldnames(data);

sizes = zeros(length(fnames),1);
for k=1:length(fnames)
	f = data.(fnames{k});
	sizes(k) = numel(f);
end

[sizes2,idxes] = sort(sizes,'descend');

info = [];
img = data.(fnames{idxes(1)});

if isfield(data,'info')
	info = data.info;
end






