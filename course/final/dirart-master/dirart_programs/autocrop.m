function [imout,x1,x2,y1,y2] = autocrop(imin,val)
% This function crops out the boundary (white or black) of the image.
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2006, dyang@radonc.wustl.edu
%
%
im2=mean(imin,3);
im2a=min(im2,[],1);
x1=find(im2a<val,1,'first');
x2=find(im2a<val,1,'last');
im2b=min(im2,[],2);
y1=find(im2b<val,1,'first');
y2=find(im2b<val,1,'last');
imout=imin(y1:y2,x1:x2,:);

figure;
subplot(121);
imagesc(imin,[min(imin(:)),max(imin(:))]);
subplot(122);
imagesc(imout,[min(imin(:)),max(imin(:))]);
