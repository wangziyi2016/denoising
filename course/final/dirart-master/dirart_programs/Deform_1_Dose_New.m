function newdose=Deform_1_Dose_New(handles,dose2deform,output_association)
%
%	newdose=Deform_1_Dose_New(handles,dose2deform,output_association)
%
dose = handles.ART.dose{dose2deform};
if dose.association == 1
	% the dose is on the moving image, use DVF
	tvf = Compute_TVF_New(handles.reg.dvf,handles.reg.images_setting.images_alignment_points(2,:),handles.images(1),handles.reg.images_setting.images_alignment_points(1,:));
else
	% the dose is on the fixed image, use IDVF
	tvf = Compute_TVF_New(handles.reg.idvf,handles.reg.images_setting.images_alignment_points(1,:),handles.images(2),handles.reg.images_setting.images_alignment_points(2,:));
end

tvf.x(isnan(tvf.x)) = 1e8;
tvf.y(isnan(tvf.y)) = 1e8;
tvf.z(isnan(tvf.z)) = 1e8;

newdose = deform_image(dose,tvf);
newdose = CopyFields(tvf.info,newdose,{'voxelsize','origin','voxel_spacing_dir','GenerateBy'});
newdose = CopyFields(tvf,newdose,{'xs','ys','zs','dim'});
newdose.DICOM_Info = dose.DICOM_Info;
newdose.UID = createUID('DOSE');
newdose.original_dose_filename = dose.filename;
newdose.association = output_association;
newdose.type = 'dose';
newdose.class = class(newdose.image);

if output_association ~= 3-dose.association
	% need to shift the dose coordinate
	[newdose.origin(2),newdose.origin(1),newdose.origin(3)]=TranslateCoordinates(handles,3-dose.association,newdose.origin(2),newdose.origin(1),newdose.origin(3),newdose);
	[newdose.xs,newdose.ys,newdose.zs]=TranslateCoordinates(handles,3-dose.association,newdose.xs,newdose.ys,newdose.zs,newdose);
end

