function [planC,path] = DICOMJ_Import_2

% CERRImportDCM4CHE
% imports the DICOM data into CERR plan format. This function is based on
% the Java code dcm4che.
% written DK, WY
% copyright (c) 2001-2006, Washington University in St. Louis.
% Permission is granted to use or modify only for non-commercial, 
% non-treatment-decision applications, and further only if this header is 
% not removed from any file. No warranty is expressed or implied for any 
% use whatever: use at your own risk.  Users can request use of CERR for 
% institutional review board-approved protocols.  Commercial users can 
% request a license.  Contact Joe Deasy for more information 
% (radonc.wustl.edu@jdeasy, reversed).

global stateS
if ~isfield(stateS,'initDicomFlag')
    flag = init_ML_DICOM;
    if ~flag
        return;
    end
elseif isfield(stateS,'initDicomFlag') && ~stateS.initDicomFlag
    return;
end
 
% Get the path of the directory to be selected for import.
path = uigetdir(pwd','Select the DICOM directory to scan:');
pause(0.1);
 
if ~path
    disp('DICOM import aborted');
    return
end
 
tic;
 
hWaitbar = waitbar(0,'Scanning Directory Please wait...');
CERRStatusString('Scanning DICOM directory');
 
%wy
filesV = dir(path);
disp(path);
dirs = filesV([filesV.isdir]);
dirs(2) = [];
dirs(1).name = '';
dcmdirS = [];
 
patientNum = 1;
 
for i = 1:length(dirs)
    patient = scandir_mldcm(fullfile(path, dirs(i).name), hWaitbar, i);
    if ~isempty(patient)
        for j = 1:length(patient.PATIENT)
            dcmdirS.(['patient_' num2str(patientNum)]) = patient.PATIENT(j);
            patientNum = patientNum + 1;
        end
    end
end
if isempty(dcmdirS)
    close(hWaitbar);
    msgbox('There is no dicom data!','Application Info','warn');
    return;
end
 
close(hWaitbar);
 
selected = showDCMInfo(dcmdirS);
patNameC = fieldnames(dcmdirS);
if isempty(selected)
    return
elseif strcmpi(selected,'all')
    combinedDcmdirS = struct('STUDY',dcmdirS.(patNameC{1}).STUDY,'info',dcmdirS.(patNameC{1}).info);
    count = 0;
    for studyCount = 1:length(combinedDcmdirS.STUDY)
        for seriesCount = 1:length(combinedDcmdirS.STUDY(studyCount).SERIES)
            count = count + 1;
            newCombinedDcmdirS.STUDY.SERIES(count) = combinedDcmdirS.STUDY(studyCount).SERIES(seriesCount);
        end
    end
    combinedDcmdirS = newCombinedDcmdirS;
    for i = 2:length(patNameC)
        for j = 1:length(dcmdirS.(patNameC{i}).STUDY.SERIES)
            combinedDcmdirS.STUDY.SERIES(end+1) = dcmdirS.(patNameC{i}).STUDY.SERIES(j);
        end
    end
    % Pass the java dicom structures to function to create CERR plan
    planC = dcmdir2planC(combinedDcmdirS);
else
    % Pass the java dicom structures to function to create CERR plan
    planC = dcmdir2planC(dcmdirS.(selected)); %wy
end
 
indexS = planC{end};
 
%-------------Store CERR version number---------------%
[version, date] = CERRCurrentVersion;
planC{indexS.header}.CERRImportVersion = [version, ', ', date];



