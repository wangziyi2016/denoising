function values = random_PHI(values)
%
% Generate random patient PHI
%
if ~exist('values','var')
	values = [];
end

if ~isfield(values,'PatientAge')
	values.PatientAge = round(rand*60+15);
end
if ~isfield(values,'PatientBirthDate')
	vec = datevec(now); vec(1)=vec(1)-values.PatientAge;
	values.PatientBirthDate = datestr(vec,'yyyyddmm');
end

if ~isfield(values,'PatientWeight')
	values.PatientWeight = round(150 + (rand*2-1)*60);
end
if ~isfield(values,'PatientAddress')
	values.PatientAddress = 'Unknown';
end
if ~isfield(values,'PatientName')
	values.PatientName.FamilyName = 'Lastname';
	values.PatientName.GivenName = 'Firstname';
	values.PatientName.MiddleName = 'M';
end

if ~isfield(values,'PatientID')
	values.PatientID = sprintf('%08d',round(rand*100000000)-1);
end


