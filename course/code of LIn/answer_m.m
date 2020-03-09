function M=answer_m(Init,t,radiation) 
real_ratia=zeros(29,1);
for i=0:28
    real_ratia(i+1)=2*sqrt(8*(Init+i*t)-(Init+i*t)^2);
end
m=zeros(29,1); 
for i=1:29
    m(i)=radiation(i)/real_ratia(i);
end
M=mean(m);