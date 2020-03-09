function [ new_P ] = find_near( target_p,new_P,P )
Pnum=size(P,1);
% count dis
D=(P(:,1)-target_p(1)).^2+(P(:,2)-target_p(2)).^2;
[~,min_index]=min(D);
% add the nearest point to the new_p
target_p=P(min_index,:);

new_P=[new_P;target_p];
P(min_index,:)=[];% delet that point from P
if Pnum==1
    return
end
[ new_P ] = find_near( target_p,new_P,P );
end

