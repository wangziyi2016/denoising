function planC = AddDoseToPlanC(handles,filename)
%
%	planC = AddDoseToPlanC(handles,planC)
%	planC = AddDoseToPlanC(handles)
%	planC = AddDoseToPlanC(handles,CERRfilename)
%
dosestrs = GenerateDoseDescriptionList(handles.ART.dose);
doseidx = max(WhichDoseToDisplay(handles,1),1);
[sel,ok] = listdlg('ListString',dosestrs,'SelectionMode','single','ListSize',[200 150],...
	'PromptString','Select a dose to save','InitialValue',doseidx,'Name','Add dose to CERR plan');
if ok == 0
	return;
end

if ~exist('filename','var')
	[filename, pathname] = uigetfile({'*.mat'}, 'Enter a CERR filename to add the selected dose');
	if filename == 0
		return;
	end
	filename = [pathname filename];
	load(filename);
elseif ischar(filename)
	load(filename);
else
	planC = filename;
end

dose = handles.ART.dose{sel};
CERR_Dose_Struct = Update_CERR_Dose_Struct(dose.original_CERR_Dose_Struct,dose);
CERR_Dose_Struct.doseArray = dose.image/100;
CERR_Dose_Struct.doseUnits = 'GRAYS';
indexS = planC{end};
planC{indexS.dose}(end+1) = CERR_Dose_Struct;

if ischar(filename)
	[filenameout, pathname] = uiputfile({'*.mat'}, 'Enter a CERR filename to save the new plan');
	if filenameout == 0
		return;
	end
	filenameout = [pathname filenameout];
	save(filenameout,'planC');
end
