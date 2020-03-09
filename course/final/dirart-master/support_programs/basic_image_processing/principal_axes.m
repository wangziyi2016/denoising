function [V,D,P] = principal_axes(img)
%
% Function: val = principal_axes(img)
%
% Calculate the primary axes of the image
%
% By: Deshan Yang, WUSTL, 06/2006
%

img = double(img);

if length(size(img))  == 2
	[fx,fy] = gradient(img);
	X = [fx(:) fy(:)];
else
	[fx,fy,fz] = gradient(img);
	X = [fx(:) fy(:) fz(:)];
end


C = X'*X;
[V,D] = eig(C);

X2 = X.*X;
X2 = sum(X2,2);
X2 = sqrt(X2);
idx = find(X2 > 0.05*max(X2));
X3 = X(idx,:);

X4 = X3*V;
P = sum(X4,1);

V = V*diag(sign(P));
P = P.*sign(P);

% debug
% if length(size(img))  == 2
% 	hold on;
% 	line([0 V(1,1)],[0 V(2,1)]);
% 	line([0 V(1,2)],[0 V(2,2)]);
% 	daspect([1 1 1]);
% end