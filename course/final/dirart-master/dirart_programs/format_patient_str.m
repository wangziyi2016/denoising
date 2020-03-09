function patientstr = format_patient_str(formatstr,lastname,firstname,id)
%
%	patientstr = format_patient_str(formatstr,lastname,firstname,id)
%
patientstr = 'file';
if ~isempty(formatstr)
	patientstr = '';
	while 1
		[token,formatstr] = strtok(formatstr,'$');
		if isempty(token)
			break;
		end
		
		if upper(token(1)) == 'L'
			% patient last name
			if length(token) > 1
				patientstr = [patientstr lastname token(2:end)];
			else
				patientstr = [patientstr lastname];
			end
		elseif upper(token(1)) == 'F'
			% patient first name			
			if length(token) > 1
				patientstr = [patientstr firstname token(2:end)];
			else
				patientstr = [patientstr firstname];
			end
		elseif length(token) >= 2 && strcmpi(token(1:2),'ID') == 1
			% patient ID
			if length(token) > 1
				patientstr = [patientstr id token(3:end)];
			else
				patientstr = [patientstr id];
			end
		end
	end
end





