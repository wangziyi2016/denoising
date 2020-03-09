% function dicomanon_philips(src_temp, dest_temp)
% Anonymize Philips Brilliance 16 CT DICOM files 
% Need to remove three fields that are UNDEFINED for some Philips images
% Input: 
%         src_temp:             source DICOM file name
%         dest_temp:            destination DICOM file name

%         
% Wei Lu
% 1/22/05

function dicomanon_philips(src_temp, dest_temp)

    metadata = dicominfo(src_temp);        
    X = dicomread(metadata);
    
    % Remove three UNDEFINED fields if exist
    field = 'PerformedProtocolCodeSequence'; rmflag = false;
    if( isfield(metadata, field) )
        val = getfield(metadata, field);
        if( isfield(val.Item_1, 'CodeValue') )
            if (strcmp(val.Item_1.CodeValue, 'UNDEFINED') )
                rmflag = true;
            end;
        end;
        if( isfield(val.Item_1, 'CodeMeaning') )
            if (strcmp(val.Item_1.CodeMeaning, 'UNDEFINED') )
                rmflag = true;
            end;
        end;
        if(rmflag) metadata = rmfield(metadata, field); end;;
    end;

    field = 'PerformedProcedureStepID';
    if( isfield(metadata,  field) )
        val = getfield(metadata,  field);
        if(strcmp(val, 'UNDEFINED'))   metadata = rmfield(metadata, field);   end;
    end;

    field = 'PerformedProcedureStepDescription';
    if( isfield(metadata,  field) )
        val = getfield(metadata,   field);
        if(strcmp(val, 'UNDEFINED'))   metadata = rmfield(metadata,  field);    end;
    end;
    
%     Not necessary. These two fields appeared in the latest DICOM header, but were not in the old DICOM header.    
%     metadata.IconImageSequence = tempIconImageSequence;
%     metadata.Private_01f1_104d = 'yes';      
     dicomwrite(X, dest_temp, metadata);
     dicomanon(dest_temp, dest_temp);
         
return;