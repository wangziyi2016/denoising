function [xVals yVals zVals] = GetDICOMXYZVals(CERRStruct)
%
% [xVals, yVals, zVals] = GetDICOMXYZVals(CERRStruct)
%
% CERRStruct could be either a scanStruct or a doseStruct from CERR
% Output unit is mm
%
if isfield(CERRStruct,'imageType')
	% this is a dose struct
	if isfield(CERRStruct,'DICOMHeaders') && ~isempty(CERRStruct.DICOMHeaders)
		info = CERRStruct.DICOMHeaders;
		xVals = single((1:info.Columns)-1)*info.PixelSpacing(1)*info.ImageOrientationPatient(1) + info.ImagePositionPatient(1);
		yVals = single((1:info.Rows)-1)*info.PixelSpacing(2)*info.ImageOrientationPatient(5) + info.ImagePositionPatient(2);
		zVals = MakeRowVector(info.ImagePositionPatient(3)+info.GridFrameOffsetVector);
	else
		[xVals yVals zVals] = GetDoseXYZVals(CERRStruct);
		xVals = xVals*10;	% from cm to mm
		yVals = yVals*10;
		zVals = zVals*10;
	end
else
	% this is a scan struct
	if isfield(CERRStruct.scanInfo(1),'DICOMHeaders') && ~isempty(CERRStruct.scanInfo(1).DICOMHeaders)
		info = CERRStruct.scanInfo(1).DICOMHeaders;
		xVals = single((1:info.Columns)-1)*info.PixelSpacing(1)*info.ImageOrientationPatient(1) + info.ImagePositionPatient(1);
		yVals = single((1:info.Rows)-1)*info.PixelSpacing(2)*info.ImageOrientationPatient(5) + info.ImagePositionPatient(2);

		N = length(CERRStruct.scanInfo);
		zVals = zeros(1,N);
		for k = 1:N
			zVals(k) = CERRStruct.scanInfo(k).DICOMHeaders.ImagePositionPatient(3);
		end
	else
		[xVals yVals zVals] = GetScanXYZVals(CERRStruct);
		xVals = xVals*10;	% from cm to mm
		yVals = yVals*10;
		zVals = zVals*10;
	end
end
