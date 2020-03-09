function newdose=Deform_1_Dose(handles,dose2deform,output_association)
%
%	newdose=Deform_1_Dose(handles,dose2deform,output_association)
%
dose = handles.ART.dose{dose2deform};

off = GetOffsetInCoordinates(handles) + handles.images(1).origin - handles.images(2).origin;
if dose.association == 1
	% the dose is on the moving image, use DVF
	tvf = ComputeTVF(handles.reg.dvf,handles.images(2),handles.images(1),handles.reg.images_setting.image_current_offsets);
else
	% the dose is on the fixed image, use IDVF
	tvf = ComputeITVF(handles.reg.idvf,handles.images(2),handles.images(1),handles.reg.images_setting.image_current_offsets);
end

newdose = deform_image(dose,tvf);
newdose.DICOM_Info = dose.DICOM_Info;
newdose.UID = dose.UID;
newdose.original_dose_filename = dose.filename;
newdose.association = output_association;
newdose.type = 'dose';
newdose.class = class(newdose.image);

if output_association ~= 3-dose.association
	% need to shift the dose coordinate
	if output_association == 2
		off = -off;
	end
	newdose.origin = newdose.origin + off;
	newdose.xs = newdose.xs+off(2);
	newdose.ys = newdose.ys+off(1);
	newdose.zs = newdose.zs+off(3);
end

