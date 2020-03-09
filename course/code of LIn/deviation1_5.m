function dev=deviation1_5(phi,a,r,t,M,left,bottom,radiation) 
real_num=zeros(512,1);
if phi>0
    for k=-256:255
        if phi<atand((left-50)/(bottom-50))+180 
            b=(r+(0.5+k)*t)/cosd(phi);
        else
            b=-(r+(0.5+k)*t)/cosd(phi);
        end
        if abs(b^2-1375)/(a^2+1)<225||b^2-1375<0
            real_num(k+257)=sqrt((a*b/800)^2-4*(a^2/1600+1/225)*(b^2/ 1600-1))/(a^2/1600+1/225)*sqrt(1+a^2);
        end
        if abs(45*a+b)/sqrt(a^2+1)<4
            real_num(k+257)=real_num(k+257)+2*sqrt(16-(45*a+b)^2/(a^2+1));
        end
    end
else
    for k=-256:255
        if phi>atand((left-50)/(bottom-50))
            b=(r+(0.5+k)*t)/cosd(phi);
        else
            b=-(r-(0.5+k)*t)/cosd(phi);
        end
        if abs(b^2-1375)/(a^2+1)<225||b^2-1375<0
            real_num(k+257)=sqrt((a*b/800)^2-4*(a^2/1600+1/225)*(b^2/ 1600-1))/(a^2/1600+1/225)*sqrt(1+a^2);
        end
        if abs(45*a+b)/sqrt(a^2+1)<4
            real_num(k+257)=real_num(k+257)+2*sqrt(16-(45*a+b)^2/(a^2+1));
        end
    end
end
end
real_num=M*real_num; dev=sum((radiation-real_num).^2);
