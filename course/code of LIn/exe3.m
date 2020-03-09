load attch2
radiation=attch2; 
real_phi=zeros(180,0);
for i=1:180
    Dev=inf;
    for phi=i-61.9:0.0001:i-60.1
        a=tand(phi);
        r=abs(-a*(left-50)+(bottom-50))/sqrt(a^2+1);
        dev=deviation1_5(phi,a,r,t,M,left,bottom,radiation(:,i)); 
        if dev<Dev
            Dev=dev;
            Phi=phi;
        end
    end
    real_phi(i)=Phi;
end
 

