function [masks,ROInames,zs]=get_structure_mask_from_dicom_wo_resample(filename,ctdim,ctinfo)
%
% [masks,ROInames,xs,ys,zs] = export_contour(filename,ctdim,ctinfo)
%
% ctdim:	Dimension of CT images
% ctinfo:	Dicom Info of CT images
% zsinput:	CT slice z values
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

disp('Loading dicominfo');
info = dicominfo(filename);
ps = ctinfo.PixelSpacing;
pp = ctinfo.ImagePositionPatient;

ROI = 1;
surfaces = zeros(ctdim,'uint8');

zsinc = abs(zsinput(2)-zsinput(1));

while 1		% For each structure
	roi_item = sprintf('Item_%d',ROI);
	if isfield(info.StructureSetROISequence,roi_item)
		ROIinfo = info.StructureSetROISequence.(roi_item);
		ROIName = ROIinfo.ROIName;
		disp(sprintf('Processing contours for %s ...',ROIName));
		ROIContour = info.ROIContourSequence.(roi_item);
		color = ROIContour.ROIDisplayColor;
		ContourSequence = ROIContour.ContourSequence;
		
		c = 0;
		mask3d = zeros(ctdim,'uint8');

		zs = [];
		
		while 1		% For each contour
			c_item = sprintf('Item_%d',c+1);
			if isfield(ContourSequence,c_item)
%				disp(sprintf('For %s : contour %d',ROIName,c+1));
				item = ContourSequence.(c_item);
				xyz = reshape(item.ContourData,3,item.NumberOfContourPoints);
				x = round((xyz(2,:) - pp(2)) / ps(2) + 0.5);	% Converting to pixel unit
				y = round((xyz(1,:) - pp(1)) / ps(1) + 0.5);
				
				x = max(x,1); x = min(x,ctdim(2));
				y = max(y,1); y = min(y,ctdim(1));
				
				z = xyz(3,:);
				idx = find( abs(zsinput - z(1)) < zsinc/2);
				if isempty(idx)
					warning(sprintf('z = %d not found',z(1)));
				else
					mask3d(:,:,idx) = mask3d(:,:,idx) + uint8(poly2mask(y,x,ctdim(1),ctdim(2)));
					for k=1:length(y)
						surfaces(x(k),y(k),idx) = ROI;
					end
				end
			else
				disp(sprintf('Totally %d 2D contours found for %s',c,ROIName));
				%mask3d = flipdim(mask3d,3);
% 				save(sprintf('%s_mask3d.mat',ROIName),'mask3d');
				break;
			end
			c = c+1;
		end
		
		masks{ROI} = mask3d;
		ROInames{ROI} = ROIName;
	else
		disp('All finished');
		break;
	end
	
	ROI = ROI+1;
end

