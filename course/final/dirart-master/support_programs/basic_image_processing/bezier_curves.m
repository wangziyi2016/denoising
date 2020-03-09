function [Bx, By]=bezier_curves(x,y,nt,init)
% Bezier curve smoothing
% Written by issam El Naqa, Date: 11/22/05
% Bezier curve smoothing
% Written by issam El Naqa, Date: 11/22/05

% save xy.mat x y;		% For debug purpose

ln=length(x);
if ln <4
    error('At least 4 points are required!');
end
if ~exist('nt')
    nt=10; % smoothness inter-spacing
end
if ~exist('init')
    init=1;
end
% use 4-control points at a time starting from 'init'
N=4;
lk=ceil(ln/N);
vec=[1:4];
[Bx,By]=bezier(x(vec),y(vec),nt);  % initialize

for k=2:lk
    index=(k-1)*N+vec-1;
    indc=find(index>ln);
    if isempty(indc)
        Px=x(index);
        Py=y(index);
        [Bxtemp,Bytemp]=bezier(Px,Py,nt);
        Bx=[Bx;Bxtemp(:)];
        By=[By;Bytemp(:)];
    else
        st=length(Bx)-length(indc); % deficiency
        Px=[Bx(st:end);x(index(1:N-length(indc)))];
        Py=[By(st:end);y(index(1:N-length(indc)))];
        [Bxtemp,Bytemp]=bezier(Px,Py,nt);    
%         Bxtemp(1:length(indc))=(Bxtemp(1:length(indc))+Bx(st:end))/2;
%         Bytemp(1:length(indc))=(Bytemp(1:length(indc))+By(st:end))/2;
        Bx=[Bx(1:st-1);Bxtemp(:)];
        By=[By(1:st-1);Bytemp(:)];
    end
end


return


function [Bx,By]=bezier(Px,Py,nt)
% Bezier equations (t=0.5) by default
t=linspace(0,1,nt); t=t(:);
Bx = (1-t).^3*Px(1) + 3*(1-t).^2 .*t.*Px(2)+3*(1-t).*t.^2.* Px(3) + t.^3.* Px(4);
By = (1-t).^3*Py(1) + 3*(1-t).^2 .*t.*Py(2)+3*(1-t).*t.^2.*Py(3) + t.^3.*Py(4);
return

