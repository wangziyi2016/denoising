
for i=2:40
   
%t=sprintf('s%d',i);
 for j=1:10
     s=sprintf('s%d\\%d.pgm',i,j);
    img=imread(s);
    s=sprintf('s%d\\%d.bmp',i,j);
    imwrite(img,s,'bmp');
 end
end
