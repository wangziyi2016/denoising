clear 
load attch2

radiation=attch2; 
radia_ratio=zeros(28,1);
for i=1:28 
    radia_ratio(i)=radiation(i)/radiation(i+1); 
end
t=golden_section1_1(8/29,8/28,radia_ratio);




