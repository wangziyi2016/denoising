function [dy,dx,dz] = gradient_2way(img)

dim = size(img);
[d1,d2,d3]=size(img);

dy = zeros(dim,'single');
dx = zeros(dim,'single');
dz = zeros(dim,'single');

dy(1:d1-1,:,:) = img(1:d1-1,:,:)-img(2:d1,:,:);
dy(d1,:,:) = 0;

dx(:,1:d2-1,:) = img(:,1:d2-1,:)-img(:,2:d2,:);
dx(:,d2,:)=0;

dz(:,:,1:d3-1) = img(:,:,1:d3-1)-img(:,:,2:d3);
dz(:,:,d3)=0;


dy2 = zeros(dim,'single');
dx2 = zeros(dim,'single');
dz2 = zeros(dim,'single');
dy2(2:d1,:,:) = dy(1:d1-1,:,:);
dy2(1,:,:)=0;

dx2(:,2:d2,:) = dx(:,1:d2-1,:);
dx2(:,1,:)=0;

dz2(:,:,2:d3) = dz(:,:,1:d3-1);
dz2(:,:,1) = 0;

grad = ((dy+dy2)/2).^2 + ((dx+dx2)/2).^2 + ((dz+dz2)/2).^2;
grad = sqrt(grad);


