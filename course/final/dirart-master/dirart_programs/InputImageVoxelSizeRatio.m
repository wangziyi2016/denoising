function [ratio,voxelsize] = InputImageVoxelSizeRatio(current_ratio,dlg_title)
%{
This is a supporting function used by the image registration GUI.


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}
if ~exist('current_ratio','var')
	current_ratio = [1 1 1];
end

prompt={'Y (mm)','X (mm)','Z (mm)'};
if exist('dlg_title','var')
	name = dlg_title;
else
	name='Voxel size in mm';
end
numlines=1;
defaultanswer={num2str(current_ratio(1),'%g'),num2str(current_ratio(2),'%g'),num2str(current_ratio(3),'%g')};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	voxelsize(1) = str2num(answer{1});
	voxelsize(2) = str2num(answer{2});
	voxelsize(3) = str2num(answer{3});
	ratio = voxelsize / voxelsize(1);
else
	ratio = [];
	voxelsize = [];
end
return;
