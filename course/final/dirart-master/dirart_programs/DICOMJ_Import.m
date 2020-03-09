function [planC,path] = DICOMJ_Import(options)

% CERRImportDCM4CHE
% imports the DICOM data into CERR plan format. This function is based on
% the Java code dcm4che.
% written DK, WY
% copyright (c) 2001-2006, Washington University in St. Louis.
% Permission is granted to use or modify only for non-commercial, 
% non-treatment-decision applications, and further only if this header is 
% not removed from any file. No warranty is expressed or implied for any 
% use whatever: use at your own risk.  Users can request use of CERR for 
% institutional review board-approved protocols.  Commercial users can 
% request a license.  Contact Joe Deasy for more information 
% (radonc.wustl.edu@jdeasy, reversed).

planC = [];
flag = init_ML_DICOM;

if ~flag
    return;
end

% Get the path of the directory to be selected for import.
path = uigetdir(pwd','Select the DICOM directory to scan:');

if ~path
    disp('DICOM import aborted');
    return
end

tic;

hWaitbar = waitbar(0,'Scanning Directory Please wait...');

%wy
filesV = dir(path);
disp(path);
dirs = filesV([filesV.isdir]);
dirs = dirs(3:end);
files = filesV(~[filesV.isdir]);
dcmdirS = [];

patientNum = 1;
if isempty(dirs)
    % Scans all the directory and returns a java structure dcmdirS
    patient = scandir_mldcm(path, hWaitbar, 1);
    
    if isempty(patient)
        close(hWaitbar);
        msgbox('There is no dicom data!','Application Info','warn');
        return;
    end
    
    for j = 1:length(patient.PATIENT)
        dcmdirS.(['patient_' num2str(patientNum)]) = patient.PATIENT(j);
        patientNum = patientNum + 1;
    end
else
    for i = 1:length(dirs)
        patient = scandir_mldcm(fullfile(path, dirs(i).name), hWaitbar, i);
        for j = 1:length(patient.PATIENT)
            dcmdirS.(['patient_' num2str(patientNum)]) = patient.PATIENT(j);
            patientNum = patientNum + 1;
        end
    end
%     msgbox('please select a dicom directory...', 'Error Directory','warn');
%     return;
end
%wy

close(hWaitbar);

if length(patient.PATIENT)==1
	dcmdir = patient.PATIENT;
else
	selected = showDCMInfo(dcmdirS);
	if isempty(selected), return; end;
	
	% Pass the java dicom structures to function to create CERR plan
	% planC = dcmdir2planC(dcmdirS.(selected)); %wy

	if isequal(selected,'all')
		dcmdir = dcmdirS;
	else
		dcmdir = dcmdirS.(selected);
	end
end

planInitC = initializeCERR;
       
indexS = planInitC{end};

%Assume a single patient for the moment
dcmdir_PATIENT = dcmdir; %wy .PATIENT{1};

%Get the names of all cells in planC.
cellNames = fields(indexS);

for i = 1:length(cellNames)
   %Populate each field in the planC.
   if exist('options','var')
	   options.CERROptions = 1;
	   if ~isfield(options,cellNames{i}) || options.(cellNames{i}) ~= 1
		   continue;
	   end
   end
   disp([' Reading ' cellNames{i}  ' ... ']);
   cellData = populate_planC_field(cellNames{i}, dcmdir_PATIENT);
   
   if ~isempty(cellData)
       planInitC{indexS.(cellNames{i})} = cellData;
   end
end

planC = planInitC;
planC = guessPlanUID(planC,0,1);
%After initial import, run any functions to address issues where
%subfunctions had insufficent data to make relationship determinations.

%process doseOffset
for doseNum = 1:length(planC{indexS.dose})
    planC{indexS.dose}(doseNum).doseOffset = min(planC{indexS.dose}(doseNum).doseArray(:));
end

% process scan zValues for US
try
    if isempty(planC{3}.scanInfo(1).zValue)
        if strcmpi(planC{3}.scanInfo(1).imageType, 'US')
            if ~isempty(planC{8})
                zValues = planC{8}.zValues;
                for i=1:length(planC{3}.scanInfo)
                   planC{3}.scanInfo(i).zValue = zValues(i); 
                end
            end
        end
    end
catch
end

%associate all structures to the first scanset.
strNum = length(planC{indexS.structures});
for i=1:strNum
	planC{indexS.structures}(i).assocScanUID = planC{indexS.scan}(1).scanUID;
end

scanNum = length(planC{3});
if (scanNum>1)
    button = questdlg(['There are ' num2str(scanNum) 'scans, do you want to put them together?'],'Merge CT in 4D Series', ...
            'Yes', 'No', 'default');
    switch lower(button)
        case 'yes'
            %sort the all scan series
            if (planC{3}(1).scanInfo(2).zValue > planC{3}(1).scanInfo(1).zValue)
                sortingMode = 'ascend';
            else
                sortingMode = 'descend';
            end
            
            zV = zeros(1, scanNum);
            for i=1:scanNum
                zV(i) = planC{3}(i).scanInfo(1).zValue;
            end
            [B,Ind] = sort(zV, 2, sortingMode);
            
            %add all scans to the first one.
            scanArray = []; scanInfo = [];
            for i=1:scanNum
                scanArray = cat(3, scanArray, planC{3}(Ind(i)).scanArray);
                scanInfo = cat(2, scanInfo, planC{3}(Ind(i)).scanInfo);
            end
            
            %delete all other scans
            planC{3} = planC{3}(1); 
            planC{3}.scanArray = scanArray;
            planC{3}.scanInfo = scanInfo;
                        
        case 'no'
                    
    end
end

%Sort contours for each structure to match the associated scan.
for i=1:length(planC{indexS.structures})
    structure = planC{indexS.structures}(i);   
    scanInd = getStructureAssociatedScan(i, planC);
	if scanInd == 0 && length(planC{indexS.scan})==1
		warning('Cannot associate structures to the scan.\n');
		scanInd=1;
	end
    
    zmesh   = [planC{indexS.scan}(scanInd).scanInfo.zValue];
    slicethickness = diff(zmesh); 
    slicethickness = [slicethickness, slicethickness(end)];
    
    ncont=length(structure.contour);
    voiZ = [];
    if ncont~=0 && ~(ncont==1 && isempty(structure.contour(1)))
        for nc=1:ncont
            if ~isempty(structure.contour(nc))
                if ~isempty(structure.contour(nc).segments)
                    voiZ(nc)=structure.contour(nc).segments(1,3);
                else
                    voiZ(nc)= NaN;
                end
            end
        end
    else
        voiZ=NaN;
    end
    [voiZ,index]=sort(voiZ);
    voiZ=dicomrt_makevertical(voiZ);
    index=dicomrt_makevertical(index);
%     slice=0;

    segmentTemplate = struct('points', []);
    segmentTemplate(1) = [];
    segmentCell = cell(length(zmesh), 1);
    [segmentCell{1:end}] = deal(segmentTemplate);
    contourTemplate = struct('segments', segmentCell);
    
    for j=1:length(zmesh) % loop through the number of CT
        locate_point=find(voiZ==zmesh(j)); % search for a match between Z-location of current CT and voiZ
        if isempty(locate_point)

            [locate_point]=find(voiZ>zmesh(j)-slicethickness(j)./2 & voiZ<zmesh(j)+slicethickness(j)./2);
            
            if isempty(locate_point)
                voi_thickness = max(diff(voiZ));
                [locate_point]=find(voiZ >= zmesh(j)-voi_thickness./2 & voiZ <= zmesh(j)+voi_thickness./2);
            end
            
            if ~isempty(locate_point)
                % if a match is found the VOI segment was defined of a
                % plane 'close' to the Z-location of the VOI
                if length(locate_point)>1
                    % if this happens we have to decide i we are dealing
                    % with multiple segments on the same slice or if
                    % mpre segments on different slices, all 'close' to the 
                    % Z-location of the CT have been 'dragged' into the
                    % selection.
                    if find(diff(voiZ(locate_point)))
                        % different segments on different slices
                        % pick the first set. Can be coded to cpick the closest 
                        % to the Z-location of CT.
                        %locate_point=locate_point(end); 
                        
%                         listZ = voiZ(locate_point);
%                         uniqZ = unique(listZ);
%                         indZ = (listZ==uniqZ(end)); %should pick the first or others?
%                         locate_point = locate_point(indZ);

                        segZ = 0;
                        segL = 0;
                        for m=1:length(locate_point)
                            seg = structure.contour(index(locate_point(m))).segments;
                            if (length(seg)>segL)
                                segL = length(seg);
                                segZ = seg(1,3);
                            end
                        end
                        listZ = voiZ(locate_point);
                        indZ = (listZ==segZ); %should pick the first or others?
                        locate_point = locate_point(indZ);
                    end
                end
                for k=1:length(locate_point)
                    %slice=slice+1;
                    segment = structure.contour(index(locate_point(k))).segments;
                    segment(:,3) = zmesh(j);
                    contourTemplate(j).segments(end+1).points = segment;
                end
            else %can not find contours in current slice, try larger radius.
                                
            end
        else
            % if match is found it's because this segment(s) of the VOI was(were) defined at the Z-location 
            % of the current CT
            for k=1:length(locate_point)
                % store all the segments with the Z location of the current CT.
%                 slice=slice+1;
                segment = structure.contour(index(locate_point(k))).segments;
                segment(:,3) = zmesh(j);
                contourTemplate(j).segments(end+1).points = segment;
            end
        end
        clear locate_point;
    end

    planC{indexS.structures}(i).contour = contourTemplate;
    planC{indexS.structures}(i).associatedScan = scanInd;
    
end

%TEMPORARY.
for i=1:length(planC{indexS.dose})
   planC{indexS.dose}(i).assocScanUID = planC{indexS.scan}(1).scanUID; 
end

if ~isempty(planC{indexS.structures})
	planC = getRasterSegs(planC);
end
planC = setUniformizedData(planC);

