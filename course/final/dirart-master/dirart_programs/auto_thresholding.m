function T=auto_thresholding(x,T0)
% automatic threshold value selection by Sonka 99
% Written by Issam El Naqa
% x: input image
% T0: initial value
% T: output threshold value
T=T0;    
while(1)
    nbody=x(find(x<=T));
    body=x(find(x>T));
    mun=mean2(nbody);
    mub=mean2(body);
    T0=T;
    T=(mun+mub)/2;
    if (abs(T-T0)<1e-6)
        break;
    end
end

return