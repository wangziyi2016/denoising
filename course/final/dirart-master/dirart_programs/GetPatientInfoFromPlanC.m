function [name,id,lastname,firstname,middlename]=GetPatientInfoFromPlanC(planC)
%
% [name,id,lastname,firstname,middlename]=GetPatientInfoFromPlanC(planC)
% [name,id,lastname,firstname,middlename]=GetPatientInfoFromPlanC, will use the global planC
%

name = [];
id = '';
lastname = '';
firstname = '';
middlename = '';

if ~exist('planC','var')
	global planC;
	if isempty(planC)
		uiwait(msgbox('Cannot access planC, quit'));
		return;
	end
end

indexS = planC{end};
scans = planC{indexS.scan};
N = length(scans);
for k = 1:N
	scan = scans(k);
	if ~isfield(scan.scanInfo(1),'DICOMHeaders') || isempty(scan.scanInfo(1).DICOMHeaders)
		continue;
	end
	
	DICOMHeader = scan.scanInfo(1).DICOMHeaders;
	[name,id,lastname,firstname,middlename]=GetPatientInfoFromDICOM(DICOMHeader);
	return;
end

doses = planC{indexS.dose};
N = length(doses);
for k = 1:N
	dose = doses(k);
	if ~isfield(dose,'DICOMHeaders') || isempty(dose.DICOMHeaders)
		continue;
	end
	
	DICOMHeader = dose.DICOMHeaders;
	[name,id,lastname,firstname,middlename]=GetPatientInfoFromDICOM(DICOMHeader);
	return;
end


