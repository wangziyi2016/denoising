function params = detImaParams( filename);
%
% Sebastian Thees 17.2.2001, email: s_thees@yahoo.com
%
% Dept. of Neurologie, Charite, Berlin, Germany
%
% params = struct(
%                 name: string
%                 date: string
%                 time: string
%              seqType: string
%      acquisitionTime: double
%             normVect: [3x1 double]
%              colVect: [3x1 double]
%              rowVect: [3x1 double]
%          centerPoint: [3x1 double]
%    distFromIsoCenter: double
%                  FoV: [2x1 double]
%       sliceThickness: double
%           distFactor: double
%              repTime: double
%            scanIndex: double
%            angletype: [7x1 char]
%                angle: [4x1 char]
%               matrix: [2x1 douuble]
%              nSlices: double
%             isMosaic: int
%              imaSize: int
% )
fid = fopen( filename, 'r', 's');

% who and when
fseek( fid, 768, 'bof');
params.name = sscanf( char( fread( fid, 25, 'uchar')), '%s');
fseek( fid, 12, 'bof');
date = fread( fid, 3, 'uint32');
params.date = sprintf( '%d.%d.%d', date(3),date(2),date(1));
fseek( fid, 52, 'bof');
time = fread( fid, 3, 'uint32');
params.time = sprintf( '%d:%d:%d', time(1),time(2),time(3));

%scan stuff
fseek( fid, 3083, 'bof'); %sequenzeType
params.seqType = sscanf( char(fread( fid, 8, 'uchar')), '%s');

fseek( fid, 2048, 'bof'); % acquisition Time
params.acquisitionTime = fread( fid, 1, 'double');


%geometrical stuff
fseek( fid, 3792, 'bof');
params.normVect = fread( fid, 3, 'double');
fseek( fid, 3856, 'bof');
params.colVect = fread( fid, 3, 'double');
fseek( fid, 3832, 'bof');
params.rowVect = fread( fid, 3, 'double');
fseek( fid, 3768, 'bof');
params.centerPoint = fread( fid, 3, 'double');

fseek( fid, 3816, 'bof');
params.distFromIsoCenter = fread( fid, 1, 'double');

% sliceParams ...
fseek( fid, 3744, 'bof');
params.FoV = fread( fid, 2, 'double');

%fseek( fid, 5000, 'bof');
%params.pixelSize = fread( fid, 2, 'double');

fseek( fid, 1544, 'bof');
params.sliceThickness = fread( fid, 1, 'double');

fseek( fid, 1560, 'bof');
params.repTime = fread( fid, 1, 'double');

fseek( fid, 5726, 'bof');
params.scanIndex = str2num( sscanf( char(fread( fid, 3, 'uchar')), '%s'));

fseek( fid, 5814, 'bof');
params.angletype = char( fread( fid, 7, 'uchar'));
fseek( fid, 5821, 'bof');
params.angle = char( fread( fid, 4, 'uchar'));
%
% fourier transform MRI leeds to a squared image matrix:
fseek(fid, 2864, 'bof'); 
params.matrix(1) = fread( fid, 1, 'uint32');
params.matrix(2) = params.matrix(1);
%
fseek(fid, 1948, 'bof');
params.imaSize=fread( fid, 1, 'int32')/2;

% total imageSize
fseek(fid, 4994, 'bof'); params.imaDim = fread( fid, 2, 'short');

fseek(fid, 3984, 'bof'); p=fread(fid, 1, 'uint32');
if p~=0 % number of partitions not zero (-> 3D dataset)
   params.nSlices=p;
   params.distFactor = 0;
else
   fseek( fid, 4004, 'bof'); params.nSlices = fread( fid, 1, 'uint32');
   fseek( fid, 4136, 'bof'); params.distFactor = fread( fid, 1, 'double');
end

% estimate if file is mosaic or not
params.isMosaic=0; params.nX=1; params.nY=1;
% calculation of mosaic format assumes a "squared" format !!!
n = sqrt( params.imaSize/(params.matrix(1)*params.matrix(2)));
if (n>1) & (int32(n)==n)
   params.isMosaic=1;
   params.nX = params.imaDim(1)/params.matrix(1);
   params.nY = params.imaDim(2)/params.matrix(2);
end
fclose( fid);