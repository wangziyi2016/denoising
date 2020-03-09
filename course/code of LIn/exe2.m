radiation=xlsread('question1_1.xlsx','sheet2','A1:A29'); 
radia_ratio=zeros(28,1);
for i=1:28 
    radia_ratio(i)=radiation(i)/radiation(i+1); 
end
[Init,R]=initial1_1(t,radia_ratio); 
right=1+Init+(256.5-46)*t;
left=100-right;
radiation=xlsread('question1_1.xlsx','sheet3','A1:A40'); 
radia_ratio=zeros(39,1);
for i=1:39 
    radia_ratio(i)=radiation(i)/radiation(i+1); 
end
[Init,R]=initial1_3(t,radia_ratio); 
bottom=10+Init+(256.5-90)*t; 
top=100-bottom;