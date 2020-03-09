function dose = Load_Dose_DICOMRT(wholename)
%
%	dose = Load_Dose_DICOMRT(wholename);
%	dose = Load_Dose_DICOMRT;
%
dose = [];

if ~exist('wholename','var')
	[filename,pathname] = uigetfile({'*.dcm','DICOM Dose file (*.dcm)';'*.*','All files'}, 'Load DICOM Dose file');
	if filename == 0
		return;
	end

	wholename = [pathname filesep filename];
end

[filenamect,pathnamect] = uigetfile({'*.dcm','DICOM CT file (*.dcm)';'*.*','All files'}, 'Load DICOM CT file');
if filenamect == 0
	return;
end
wholenamect = [pathnamect filesep filenamect];
ctinfo = dicominfo(wholenamect);
doseinfo = dicominfo(wholename);

PatientPositionCODE = dicomrt_getPatientPosition(ctinfo);
planC = initializeCERR;
info_Image{1} = doseinfo;
planC = loadDose(info_Image,planC,PatientPositionCODE,'');
dose = Load_Dose_CERR(planC);
dose.LoadFrom = 'DICOM via CERR';


	


