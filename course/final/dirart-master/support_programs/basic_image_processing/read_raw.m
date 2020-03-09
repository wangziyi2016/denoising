function im = read_raw(filename,dim,datatype,offset)

fid=fopen(filename,'r','ieee-le');
header=fread(fid,offset,'uchar');
im=fread(fid,prod(dim),datatype);
im = reshape(im,dim);
fclose(fid);
