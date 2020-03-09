function [ new_P ] = find_center( LI )
num=max(max(LI));
P=zeros(num,2);
for j=1:num
    [m,n]=find(LI==j);
    P(j,:)=[mean(n),mean(m)];
end
% make it in order 
[~,min_index]=max(P(:,1));
target_p=P(min_index,:);
P(min_index,:)=[];
new_P=target_p;
[ new_P ] = find_near( target_p,new_P,P );
end

