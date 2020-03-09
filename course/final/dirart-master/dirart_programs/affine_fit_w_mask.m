function [vx2,vy2,vz2]=affine_fit_w_mask(vx,vy,vz,mask,gridsize)
%
% Affine fit each motion field
%
% Dividing the entire field into overlapping windows, performing affine
% fitting for each window, and then perform averaging on nearby windows
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2006, dyang@radonc.wustl.edu
%
dim = size(vx);

if ~exist('gridsize') | isempty(gridsize)
	gridsize = 8;
else
	gridsize = ceil(gridsize/2)*2;
end

x1sa = 1:gridsize:dim(2); if (dim(2)-x1sa(end)+1 < gridsize/2) x1sa = x1sa(1:end-1); end
x2sa = x1sa+(gridsize-1); x2sa = min(x2sa,dim(2));
y1sa = 1:gridsize:dim(1); if (dim(1)-y1sa(end)+1 < gridsize/2) y1sa = y1sa(1:end-1); end
y2sa = y1sa+(gridsize-1); y2sa = min(y2sa,dim(1));
z1sa = 1:gridsize:dim(3); if (dim(3)-z1sa(end)+1 < gridsize/2) z1sa = z1sa(1:end-1); end
z2sa = z1sa+(gridsize-1); z2sa = min(z2sa,dim(3));

x1sb = 1+gridsize/2:gridsize:dim(2); if (dim(2)-x1sb(end)+1 < gridsize/2) x1sb = x1sb(1:end-1); end
x2sb = x1sb+(gridsize-1); x2sb = min(x2sb,dim(2));
y1sb = 1+gridsize/2:gridsize:dim(1); if (dim(1)-y1sb(end)+1 < gridsize/2) y1sb = y1sb(1:end-1); end
y2sb = y1sb+(gridsize-1); y2sb = min(y2sb,dim(1));
z1sb = 1+gridsize/2:gridsize:dim(3); if (dim(3)-z1sb(end)+1 < gridsize/2) z1sb = z1sb(1:end-1); end
z2sb = z1sb+(gridsize-1); z2sb = min(z2sb,dim(3));
x1sb=[1 x1sb]; x2sb=[gridsize/2 x2sb];
y1sb=[1 y1sb]; y2sb=[gridsize/2 y2sb];
z1sb=[1 z1sb]; z2sb=[gridsize/2 z2sb];

m1=[0:gridsize/2-1 gridsize/2:-1:1];
m2=gridsize/2-m1;
xm1 = m1(mod([1:dim(2)]-1,gridsize)+1)/gridsize*2;
xm2 = m2(mod([1:dim(2)]-1,gridsize)+1)/gridsize*2;
ym1 = m1(mod([1:dim(1)]-1,gridsize)+1)/gridsize*2;
ym2 = m2(mod([1:dim(1)]-1,gridsize)+1)/gridsize*2;
zm1 = m1(mod([1:dim(3)]-1,gridsize)+1)/gridsize*2;
zm2 = m2(mod([1:dim(3)]-1,gridsize)+1)/gridsize*2;

mul1 = ones(dim,'single');
mul2 = mul1;

[x,y,z]=meshgrid(xm1,ym1,zm1);
mul1 = x.*y.*z;

[x,y,z]=meshgrid(xm2,ym2,zm2);
mul2 = x.*y.*z;
clear x y z;

mulsum = mul1+mul2;
mul1 = mul1./mulsum;
mul2 = mul2./mulsum;
mul1(mulsum==0)=0.5;
mul2(mulsum==0)=0.5;

vx2=zeros(dim,'single');
vy2=vx2;vz2=vx2;vx3=vx2;vy3=vx2;vz3=vx2;
ny = length(y1sa); nx = length(x1sa); nz = length(z1sa);
H = waitbar(0,'Progress ...');
N = nx*ny*nz;
for i=1:ny
	y = [y1sa(i):y2sa(i)];
	for j=1:nx
		x = [x1sa(j):x2sa(j)];
		for k=1:nz
			waitbar(((i-1)*nx*nz+(j-1)*nz+k-1)/N,H,sprintf('Affine smoothing pass 1: %d-%d-%d',i,j,k));
			z = [z1sa(k):z2sa(k)];
			if (length(find(mask(y,x,z)>0)) < 24) continue; end
			[xxx,yyy,zzz]=meshgrid(x,y,z);
			[G,dx2,dy2,dz2]=affine_fit_3d(vx(y,x,z),vy(y,x,z),vz(y,x,z),xxx,yyy,zzz,mask(y,x,z));
			vx2(y,x,z) = dx2;
			vy2(y,x,z) = dy2;
			vz2(y,x,z) = dz2;
		end
	end
end

for i=1:length(y1sb)
	y = [y1sb(i):y2sb(i)];
	for j=1:length(x1sb)
		x = [x1sb(j):x2sb(j)];
		for k=1:length(z1sb)
			waitbar(((i-1)*nx*nz+(j-1)*nz+k-1)/N,H,sprintf('Affine smoothing pass 2: %d-%d-%d',i,j,k));
			z = [z1sb(k):z2sb(k)];
			if (length(find(mask(y,x,z)>0)) < 24) continue; end
			[xxx,yyy,zzz]=meshgrid(x,y,z);
			[G,dx2,dy2,dz2]=affine_fit_3d(vx(y,x,z),vy(y,x,z),vz(y,x,z),xxx,yyy,zzz,mask(y,x,z));
			vx3(y,x,z) = dx2;
			vy3(y,x,z) = dy2;
			vz3(y,x,z) = dz2;
		end
	end
end

close(H);


vx2 = vx2.*mul1+vx3.*mul2;
vy2 = vy2.*mul1+vy3.*mul2;
vz2 = vz2.*mul1+vz3.*mul2;


