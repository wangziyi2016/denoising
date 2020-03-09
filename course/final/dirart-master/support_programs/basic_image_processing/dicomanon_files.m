function dicomanon_files(filter,update_values)
%
% 1. Assign values to certain fields
%	 dicomanon_files(filter,update_values)
% 2. Given a fake patient ID
%    dicomanon_files(filter,fakePatientIDstr)
% 3. Let the program generate a random PatientID
%    dicomanon_files(filter)
%
if exist('update_values','var') && isstruct(update_values)
	values = update_values;
end

values = random_PHI(values);

d=dir(filter);

disp(sprintf('There are totally %d files',length(d)));

for k=1:length(d)
	name = d(k).name;
	if isdir(name)
		%continue;
		if strcmp(name,'.') || strcmp(name,'..')
			continue;
		else
			fprintf('\n\n-------------------\nNow processing folder: %s\n-----------------\n',name);
			cd(name);
			if exist('update_values','var')
				dicomanon_files(filter,update_values);
			else
				dicomanon_files(filter);
			end
			cd ..;
		end
	else
		newname = name;
		fprintf('File %d (%d): %s ==> %s\n',k, length(d),name, newname);

		if strcmpi(name,'DIRFILE')
			continue;
		end
		
		try
			info = dicominfo(name);
		catch
			fprintf('Skipping %s, not a dicom file.\n',name);
			continue;
		end
		
		if ~isfield(info,'PatientName')
			fprintf('Skipping %s, PatientName is not a field of dicominfo.\n',name);
			continue;
		end
		
		if isempty(findstr(lower(info.PatientName.FamilyName),'anonymize'))
			values.PatientName.FamilyName = 'Anonymized';
			values.PatientName.MiddleName = '';
			values.PatientName.GivenName = '';
			values.PatientName.GivenName(1) = info.PatientName.FamilyName(1);
		else
			values.PatientName = info.PatientName;
		end
% 		if isfield(info.PatientName,'GivenName')
% 			values.PatientName.GivenName(2) = info.PatientName.GivenName(1);
% 		end
		if values.PatientID == -1
			values.PatientID = CreatePatientID(info.PatientID);
		end
				
		fnames = fieldnames(info);
		dicomupdate(name,newname,values);
% 		dicomanon(name,newname,'keep',fnames,'update',values);
	end
end

disp('Dicomanon all finished.');

return;


function ID = CreatePatientID(ID)
a = str2num(ID');
a1 = sum(a);
a2 = prod(a);
ID = num2str(a1*a2+a1+a2*100);

return;

