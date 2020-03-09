function Dose_Deformation(handles)
%
%
%
N = length(handles.ART.dose);
if N < 1
	return;
end

h = DoseDeformationUI(handles);
uiwait;
if ishandle(h)
	data = guidata(h);
	if data.cancel == 1
		close(h);
		return;
	end

	dose2deform = get(data.Dose_List,'value');
	deformed_dose_association = get(data.Image_List,'value');
	deformed_dose_description = get(data.New_Dose_Description_Input,'string');
	close(h);

	% Deform the dose volume here
% 	newdose=Deform_1_Dose(handles,dose2deform,deformed_dose_association);
	newdose=Deform_1_Dose_New(handles,dose2deform,deformed_dose_association);
	newdose.Description = deformed_dose_description;
	newdose.association = deformed_dose_association;

	% Add the deformed dose to the dose list
	Add1Dose(handles,newdose);
end

