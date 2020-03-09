function [dy,dx,dz,grad]=im2_gradient_v2(dI2y,dI2x,dI2z,mvy,mvx,mvz)

dim = size(mvy);

% For y
d = dI2y ./ (mvy(2:end,:,:)-mvy(1:end-1,:,:)+1);
s = 1-sign(d(1:end-1,:,:).*d(2:end,:,:));

dy = zeros(dim,'single');
dy(2:end-1,:,:) = d(1:end-1,:,:) + s.*d(2:end,:,:);
dy(1,:,:) = d(1,:,:);
dy(end,:,:) = d(end,:,:);

% For x
d = dI2x ./ (mvx(:,2:end,:)-mvx(:,1:end-1,:)+1);
s = 1-sign(d(:,1:end-1,:).*d(:,2:end,:));

dx = zeros(dim,'single');
dx(:,2:end-1,:) = d(:,1:end-1,:) + s.*d(:,2:end,:);
dx(:,1,:) = d(:,1,:);
dx(:,end,:) = d(:,end,:);


% For z
d = dI2z ./ (mvz(:,:,2:end)-mvz(:,:,1:end-1)+1);
s = 1-sign(d(:,:,1:end-1).*d(:,:,2:end));

dz = zeros(dim,'single');
dz(:,:,2:end-1) = d(:,:,1:end-1) + s.*d(:,:,2:end);
dz(:,:,1) = d(:,:,1);
dz(:,:,end) = d(:,:,end);


grad = sqrt(dy.^2+dx.^2+dz.^2);

return;