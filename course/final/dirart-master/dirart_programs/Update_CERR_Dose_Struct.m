function newDoseStruct = Update_CERR_Dose_Struct(oldDoseStruct,ART_Dose)
%
%	newDoseStruct = Update_CERR_Dose_Struct(oldDoseStruct,ART_Dose)
%
newDoseStruct = oldDoseStruct;
dim = size(ART_Dose.image);
newDoseStruct.sizeOfDimension1 = dim(2);
newDoseStruct.sizeOfDimension2 = dim(1);
newDoseStruct.sizeOfDimension3 = dim(3);
newDoseStruct.coord1OFFirstPoint = double(ART_Dose.origin(2)/10);
newDoseStruct.coord2OFFirstPoint = double(ART_Dose.origin(1)/10);
newDoseStruct.horizontalGridInterval = double(ART_Dose.voxelsize(2)/10*ART_Dose.voxel_spacing_dir(2));
newDoseStruct.verticalGridInterval = double(ART_Dose.voxelsize(1)/10*ART_Dose.voxel_spacing_dir(1));
newDoseStruct.doseDescription = ART_Dose.Description;
newDoseStruct.fractionGroupID = ART_Dose.Description;
newDoseStruct.zValues = double(((1:dim(3))-1)*ART_Dose.voxelsize(3)/10*ART_Dose.voxel_spacing_dir(3)+ART_Dose.origin(3)/10);
newDoseStruct.doseUID = createUID('DOSE');
newDoseStruct.assocScanUID = ART_Dose.assocScanUID;
newDoseStruct.DICOMHeaders= [];


				
				
