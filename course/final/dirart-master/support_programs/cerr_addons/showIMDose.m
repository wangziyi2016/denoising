function showIMDose(dose3D,fractionGroupID,assocScanNum)
%Function to place dose into the running CERR plan.
%Just edit the strings below.
%JOD.
%LM:  6 Sept 05
%   APA, 11 Oct 06, Added an input param assocScanNum to link the dose to
%   this scan. Defaults to 1 if not input.


global planC;
global stateS;
indexS = planC{end};

register = 'UniformCT';  %Currently only option supported.  Dose has the same shape as the uniformized CT scan.
doseError = [];
doseEdition = 'CERR test';
description = 'Test PB distribution.';
overWrite = 'no';  %Overwrite the last CERR dose?
if ~exist('assocScanNum','var') || isempty(assocScanNum)
    assocScanNum = 1;
end
assocScanUID = planC{indexS.scan}(assocScanNum).scanUID;
dose2CERR(dose3D,doseError,fractionGroupID,doseEdition,description,register,[],overWrite,assocScanUID);

stateS.doseToggle = 1;

stateS.doseSetChanged = 1;
% stateS.CTDisplayChanged = 1;
% stateS.structsChanged = 1;

stateS.doseSet = length(planC{indexS.dose});
% stateS.doseUID = planC{indexS.dose}(end).doseUID;
sliceCallBack('refresh');
