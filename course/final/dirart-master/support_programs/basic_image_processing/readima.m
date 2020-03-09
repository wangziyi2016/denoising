function [header,a]=readima(filename,width, height,offset)
% read ima image formats
fid=fopen(filename,'r','ieee-be');
header=fread(fid,offset,'uchar');
a=fread(fid,[width,height],'ushort');
fclose(fid);
return

