function mask_out = deform_1_structure_mask(mask,mvy,mvx,mvz)
%{
	mask = deform_1_structure_mask(mask,mvy,mvx,mvz)


Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(mask);

% masky = squeeze(max(max(mask,[],3),[],2));
% maskx = squeeze(max(max(mask,[],3),[],1));
% maskz = squeeze(max(max(mask,[],1),[],2));

% y1 = find(masky>0,1,'first') - ceil(max(mvy(:))) - 2; y1 = max(y1,1);
% y2 = find(masky>0,1,'last') - floor(min(mvy(:))) + 2; y2 = min(y2,dim(1));
% x1 = find(maskx>0,1,'first') - ceil(max(mvx(:))) - 2; x1 = max(x1,1);
% x2 = find(maskx>0,1,'last') - floor(min(mvx(:))) + 2; x2 = min(x2,dim(2));
% z1 = find(maskz>0,1,'first') - ceil(max(mvz(:))) - 2; z1 = max(z1,1);
% z2 = find(maskz>0,1,'last') - floor(min(mvz(:))) + 2; z2 = min(z2,dim(3));
% 
% ys = y1:y2;
% xs = x1:x2;
% zs = z1:z2;

% dim = size(mvy);
ys = 1:dim(1);
xs = 1:dim(2);
zs = 1:dim(3);

mvy = mvy(ys,xs,zs);
mvx = mvx(ys,xs,zs);
mvz = mvz(ys,xs,zs);

% offsets = [y1 x1 z1];
offsets = [0 0 0];

temp_mask_out = uint32(round(move3dimage(single(mask),mvy,mvx,mvz,'nearest',offsets)));
% temp_mask_out = uint32(round(move3dimage(single(mask),mvy,mvx,mvz,'linear',offsets)));

mask_out = mask*0;
mask_out(ys,xs,zs) = temp_mask_out;


