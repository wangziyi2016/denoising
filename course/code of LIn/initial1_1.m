function [Init,R]=initial1_1(t,radia_ratio) 
real_ratio=zeros(28,1);
R=inf;
for init=0:0.000001:8-28*t 
    for i=0:27
        real_ratio(i+1)=sqrt(8*(init+i*t)-(init+i*t)^2)/sqrt(8*(init+(i+1)*t)-(init+(i+1)*t)^2);
    end
    r=sum((radia_ratio-real_ratio).^2); 
    if r<R
        R=r;
        Init=init;
    end
end