function [pts, valmin, valmax]=get_featuretrack3d(im,W,r,roaLM,lambTH)
% use lucas kanade feature tracker method...
% Extract good tracking features with minimum eigenvalue greater
siz=size(im);
%hmsk = [-.5 0 .5];
%hmsk=1/12*[-1,8,0,-8,1];
hmsk=[1 0 -1;2  0 -2;1 0 -1]/4;
%hmsk=[3 0 -3; 10 0 -10; 3 0 -3]/32;
pts=[];
valmin=[];
valmax=[];
Lxy=floor(W/2);
hmsk3=cat(3,hmsk,hmsk,hmsk);
vmsk3=permute(hmsk3,[2 1 3]);
zmsk3=permute(hmsk3,[3 1 2]);
ima=append3d(im,Lxy);
xgrad=keep3d(convn(ima,hmsk3,'same'),siz);
ygrad=keep3d(convn(ima,vmsk3,'same'),siz);
zgrad=keep3d(convn(ima,zmsk3,'same'),siz);
zgrad=r*zgrad;
bvec=-Lxy:Lxy;
% divide image into blocks and apply LKT
for k=1:siz(3)
    for i = 1:siz(1)
        for j = 1:siz(2)
            veci=max(min(bvec+i,siz(1)),1);
            vecj=max(min(bvec+j,siz(2)),1);
            veck=max(min(bvec+k,siz(3)),1);
            bxgrad = xgrad(veci,vecj,veck); 
            bygrad = ygrad(veci,vecj,veck); 
            bzgrad = zgrad(veci,vecj,veck);
            Jxx=sum(sum(sum(bxgrad.*bxgrad)));
            Jyy=sum(sum(sum(bygrad.*bygrad)));
            Jzz=sum(sum(sum(bzgrad.*bzgrad)));
            Jxy= sum(sum(sum(bxgrad.*bygrad)));
            Jyz= sum(sum(sum(bygrad.*bzgrad)));
            Jxz= sum(sum(sum(bxgrad.*bzgrad)));
            GST=[Jxx, Jxy, Jxz; Jxy,Jyy,Jyz; Jxz,Jyz,Jzz];
            lamb=eig(GST);
            minlamb=min(lamb);
            maxlamb=max(lamb);
            if minlamb > lambTH(1)
                roa=maxlamb/minlamb;
                if  roa <roaLM(2) & roa>roaLM(1) & maxlamb<lambTH(2)
                    vec = [i;j;k];
                    pts = [pts vec];
                    valmin = [valmin minlamb];
                    valmax = [valmax maxlamb];
                    %                             valmax(i,j,k)=max(lamb);
                    %                             valmin(i,j,k)=min(lamb);
               end
            end
        end
    end
end

return