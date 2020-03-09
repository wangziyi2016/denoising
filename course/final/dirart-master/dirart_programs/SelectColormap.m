function mapselected = SelectColormap(currentmap)
%
% mapselected = SelectColormap(currentmap)
%

mapselected = '';

colormaps = {'Jet','HSV','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','lines'};
if ~exist('currentmap','var')
	k=1;
else
	for k = 1:length(colormaps)
		if strcmpi(colormaps{k},currentmap) == 1
			break;
		end
	end
end

[Selection,ok] = listdlg('ListString',colormaps,'SelectionMode','single','InitialValue',k,...
	'Name','Colormap Selection','PromptString','Please select a colormap',...
	'ListSize',[200 200]);

if ok == 1
	mapselected = colormaps{Selection};
end


