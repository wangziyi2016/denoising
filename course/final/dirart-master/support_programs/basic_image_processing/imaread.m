function im = imaread(filename)

params = detImaParams( filename);

width = params.imaDim(2);
height = params.imaDim(1);

fid=fopen(filename,'r','ieee-be');
header=fread(fid,6144,'uchar');
im=fread(fid,[width,height],'ushort=>ushort');
fclose(fid);
