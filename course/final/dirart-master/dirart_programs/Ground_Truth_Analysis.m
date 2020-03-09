function Ground_Truth_Analysis(mvy0,mvx0,mvz0,mvy,mvx,mvz,voxelsize,mask)
%
%   Ground_Truth_Analysis(mvy0,mvx0,mvz0,mvy,mvx,mvz,voxelsize=[1 1 1])
%   Ground_Truth_Analysis(mvy0,mvx0,mvz0,mvy,mvx,mvz,voxelsize=[1 1 1],mask)
%

if ~isequal(size(mvx0),size(mvx)) || ~isequal(size(mvy0),size(mvy)) || ~isequal(size(mvz),size(mvz0))
	setinfotext('ERROR: Motion field matrix dimension mismatch');
	return;
end

erx = mvx0 - mvx;
ery = mvy0 - mvy;
erz = mvz0 - mvz;

% erx(isnan(erx))=0;
% ery(isnan(ery))=0;
% erz(isnan(erz))=0;

if ~exist('voxelsize','var')
	voxelsize = [ 1 1 1 ];
end

erx = erx*voxelsize(2);
ery = ery*voxelsize(1);
erz = erz*voxelsize(3);

if ~exist('mask','var') || isempty(mask)
	if ndims(erx) == 3
		mask = abs(mvx)>0.05 & abs(mvy)>0.05 & abs(mvz)>0.05;
	else
		mask = abs(mvx)>0.05 & abs(mvy)>0.05;
	end
end

mask = mask.*(~isnan(mvx0));

ers = sqrt(erx.^2+ery.^2+erz.^2);
% ers = ers.*mask;
ers2 = ers(mask==1);
erx = erx(mask==1);
ery = ery(mask==1);
erz = erz(mask==1);

fprintf('\n\n==================================================\n');
fprintf('Error analysis with ground truth:\n');
fprintf('==================================================\n');
fprintf('Deformation field vector:\n');
fprintf('Error LR: Mean = %.3g, std = %.3g, max = %.3g\n',mean(erx(:)),std(erx(:)), max(erx(:)));
fprintf('Error AP: Mean = %.3g, std = %.3g, max = %.3g\n',mean(ery(:)),std(ery(:)), max(ery(:)));
fprintf('Error SI: Mean = %.3g, std = %.3g, max = %.3g\n',mean(erz(:)),std(erz(:)), max(erz(:)));
fprintf('Absolute error: Mean = %.3g, std = %.3g, max = %.3g\n',mean(ers2(:)),std(ers2(:)), max(ers2(:)));
[n,xout] = hist(ers(:),20);
%n = n / numel(ers);
figure;bar(xout,log10(n));
xlabel('Absolute error (pixel)')
ylabel('Pixel count (log10)');
if ndims(ers) == 2
	figure;imagesc(ers,[0 1]);colorbar;
	impixelinfo;
	title('Absolute error (pixels)');
	axis off;axis image;
else
	view3dgui(ers);
end

if ndims(mvx) == 2
	% Compute angular errors
	ang1 = atan(mvx./mvy)*180/pi;
	ang1(isnan(ang1))=0;
	ang2 = atan(mvx./mvy)*180/pi;
	ang2(isnan(ang2))=0;
	angerr = abs(ang1-ang2);
	angerr = angerr.*mask;
	angerr = angerr(10:end-10,10:end-10,:);
	angerr(angerr>180) = 360-angerr(angerr>180);
	angerr(angerr>90) = 180-angerr(angerr>90);
	figure;imagesc(angerr);colorbar;
	impixelinfo;
	axis off;axis image;
	title('Angular errors (degree)');
	fprintf('Deformation field vector:\n');
	fprintf('Angular error: mean = %.3g, std = %.3g, max = %.3g\n',mean((angerr(:))),std((angerr(:))), max((angerr(:))));
	%fprintf('Absolute angular error: mean = %.3g, std = %.3g, max = %.3g\n',mean(abs(angerr(:))),std(abs(angerr(:))), max(abs(angerr(:))));
	[n,xout] = hist(abs(angerr(:)),20);
	%n = n / numel(angerr);
	figure;bar(xout,log10(n));
	xlabel('Absolute angle error (degree)')
	ylabel('Pixel count (log10)');
end

