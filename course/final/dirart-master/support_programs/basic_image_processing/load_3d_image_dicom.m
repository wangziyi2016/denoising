function [im3d,info,positionMatrix,orientation,pathout] = load_3d_image_dicom(filenamefilter,folderfilter)
%
% [im3d,info,positionMatrix,orientation,pathout] = load_3d_image_dicom(filenamefilter)
% [im3d,info,positionMatrix,orientation,pathout] = load_3d_image_dicom(filenamefilter,folderfilter)
% [im3d,info,positionMatrix,orientation,pathout] = load_3d_image_dicom(filenamefilter,'?') to select a folder
%
% Output: positionMatrix is the 4x3 matrix to transform image voxel indexes
% (starting from 0) to patient coordinate system. For example:
% [x,y,z] = positionMatrix*[i-1;j-1;k-1;1]; to compute the voxel (i,j,k)
% center position (x,y,z) in patient image coordinate system defined in DICOM standard. 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

n=1;
curdir = pwd;
pathname = curdir;
filename = [];
instances = [];
im3d = [];
info = [];
zs = [];
instances = [];
orientation = '';
positionMatrix = [];
pathin = '';

if exist('folderfilter','var')
	if folderfilter == '?'
		folderfilter = uigetdir('','Select the image file folder');
		if folderfilter == 0
			return;
		end
	end
	filenamefilter = [folderfilter filesep filenamefilter];
end

if ~exist('filenamefilter','var')
	filenamefilter = [];
end

if ~isempty(filenamefilter)
	filename = dir(filenamefilter);
else
	filename = dir;
end

pathstr = fileparts(filenamefilter);
if ~isempty(pathstr)
	pathout = pathstr;
	pathstr = [pathstr filesep];
end

for k = 1:length(filename)
	fprintf('.');
	%waitbar((k-1)/length(filename),H,sprintf('Loading %s ...',filename(k).name));
	if isdir([pathstr filename(k).name])
		continue;
	end
	try
		info1 = dicominfo([pathstr filename(k).name]);
		if ~isfield(info1,'PatientPosition')
			continue;
		end
		
		if isempty(info)
			% this is the first file
			% check patient orientation
			
			if sum(abs(abs(info1.ImageOrientationPatient)-[1;0;0;0;1;0])) < 0.01
				% this is transverse image
				orientation = 'tra';
			elseif sum(abs(abs(info1.ImageOrientationPatient)-[1;0;0;0;0;1])) < 0.01
				% this is coronal image
				orientation = 'cor';
			elseif sum(abs(abs(info1.ImageOrientationPatient)-[0;1;0;0;0;1])) < 0.01
				orientation = 'sag';
			else
				orientation = 'obl';
			end
			
		end
		
		info = info1;
% 		infos{n} = inf0;

		instances = [instances info.InstanceNumber];
		position(:,n) = info.ImagePositionPatient;
		im3d2(:,:,n) = dicomread([pathstr filename(k).name]);
		
		n = n+1;
	catch ME
		print_lasterror(ME);
		return;
	end
end
fprintf('\n');
% end

[dummy,idx] = sort(instances);

switch orientation
	case 'tra'
% 		pos1 = position(3,:);
% 		pos2 = pos1(idx);
% 		[pos2,idx] = unique(pos1);
% 		im3d = im3d2(:,:,idx);
	case 'cor'
% 		pos1 = position(2,:);
% 		pos2 = pos1(idx);
% 		[pos2,idx] = unique(pos1);
% 		im3d = im3d2(:,:,idx);
% 		im3d = permute(im3d,[3 2 1]);
	case 'sag'
% 		pos1 = position(1,:);
% 		pos2 = pos1(idx);
% 		[pos2,idx] = unique(pos1);
% 		im3d = im3d2(:,:,idx);
% 		im3d = permute(im3d,[2 3 1]);
	case 'obl'
% 		[dummy,idx] = sort(instances);
% 		im3d = im3d2(:,:,idx);
% 		pos2 = [];
end

im3d = im3d2(:,:,idx);
% instances = instances(idx);

pos1 = position(:,idx(1));
if length(idx)>1
	pos2 = position(:,idx(2));
else
	% 2D image
	pos2 = position(:,idx(1));
end
deltaPos = pos2-pos1;

% dx=info.PixelSpacing(1);
% dy=info.PixelSpacing(2);

positionMatrix = [reshape(info.ImageOrientationPatient,[3 2])*info.PixelSpacing(1) [deltaPos(1) pos1(1);deltaPos(2) pos1(2); deltaPos(3) pos1(3)]];
% positionMatrix = pos2;



