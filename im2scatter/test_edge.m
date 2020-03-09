% show me the edge of the object 
% Input: the image
% Output:labeled point 
close all
clear all
I=imread('gouzi2.jpg');
I_gray=rgb2gray(I);
BI=im2bw(I_gray,0.9);
BI=BI(:,1:end-40);
imshow(BI)
%BI=~BI;
BI=flipud(BI);
BW2 = bwperim(BI,8);
BW2=bwmorph(BW2,'thin',Inf);
imshow(BW2)

%swtich it to point list
[m,n]=find(BW2==1);
P=[n,m];
new_P=[];
%choose one point as beginning point
[max_value,max_index]=min(m);
%make it in order
[ new_P ] = find_near( P(max_index,:),new_P,P);
Pnum=size(P,1);
scatter(new_P(:,1),new_P(:,2));
hold on 
scatter(new_P(1,1),new_P(1,2),'r*')

