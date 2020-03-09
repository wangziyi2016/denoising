%Frost filter for speckle noise reduction
%Author : Jeny Rajan
function [ft]=frost(I)
% I is the noisy input image
tic
[x y z]=size(I);
I=double(I);
K=1;
N=I;
for i=1:x
    for j=1:y                              
        if (i>1 & i<x & j>1 & j<y)
            mat(1)=I(i-1,j);
            mat(2)=I(i+1,j);
            mat(3)=I(i,j-1);
            mat(4)=I(i,j+1);
            d(1)=sqrt((i-(i-1))^2);
            d(2)=sqrt((i-(i+1))^2);
            d(3)=sqrt((j-(j-1))^2);
            d(4)=sqrt((j-(j+1))^2);
            mn=mean(mean(mat));
            c=mat-mn;
            c2=c.^2;
            c3=c/(c2+.0000001);
            Cs=0.25*sum(sum(c3));
            m(1)=exp(-K*Cs*d(1));
            m(2)=exp(-K*Cs*d(2));
            m(3)=exp(-K*Cs*d(3));
            m(4)=exp(-K*Cs*d(4));
            ms=sum(sum(m));
            mp=m/ms;
            N(i,j)=sum(sum(mp.*mat));                    
        end
     end
end
toc
% ft=uint8(N);
ft = N;

