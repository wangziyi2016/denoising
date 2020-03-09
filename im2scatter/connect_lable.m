% connect label
clear all
I=imread('face1.png');
SE=strel('arbitrary',eye(2)) ;
level=graythresh(I);
BI=im2bw(I,level);
BI=~BI;
BI=flipud(BI);
LI = bwlabel(BI);
[ P ] = find_center( LI );
figure
hold on
Pnum=size(P,1);
for j=1:Pnum
    scatter(P(j,1),P(j,2));
    pause(0.01)
end