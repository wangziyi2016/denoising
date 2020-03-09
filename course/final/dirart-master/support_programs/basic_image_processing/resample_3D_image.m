function [img3dout,voxel_dim_dst] = resample_3D_image(img3din,info,varargin)
%
% Usage: 
%	[img3dout,voxel_dim_dst] = resample_3d_image(img3din,info,[options])
%
% Input:
%	info:		dicominfo of the 3D image
%				info can also be a voxel dimension vector as [dx,dy,dz]
%	img3din:	the 3D image in MATLAB .mat file
% Option input:
%	'spacing' or 'pixel_spacing'		pixel spacing on the transverse slice
%	'thickness' or 'slice_thickness'	slice thickness
%	'interpolation'						the interpolation method
% Output:
%	img3dout:	resample 3D image
%
% This function will use resample the 3D image into the spatial resolution
% set in the options, The resample method is basic biliner interpolation.
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

options.pixel_spacing = 2.5;
options.slice_thickness = 2.5;
options.interpolation_method = 'linear';

for k = 1:length(varargin)
	if ischar(varargin{k})
		switch lower(varargin{k})
			case {'spacing','pixel_spacing'}
				if k < length(varargin) && ~ischar(varargin{k+1})
					options.pixel_spacing = varargin{k+1};
					options.pixel_spacing = options.pixel_spacing(1);
				end
			case {'thickness','slice_thickness'}
				if k < length(varargin) && ~ischar(varargin{k+1})
					options.slice_thickness = varargin{k+1};
				end
			case {'interpolation'}
				if k < length(varargin) && ischar(varargin{k+1})
					options.interpolation_method = varargin{k+1};
				end
		end
	end
end

if isstruct(info) && isfield(info,'PixelSpacing')
	voxel_dim_src = [info.PixelSpacing; info.SliceThickness];
else
	voxel_dim_src = info;
end

if ~isnumeric(voxel_dim_src) || length(voxel_dim_src) ~= 3
	error(2,'Wrong dicominfo or wrong voxel dimension on the 2nd input');
end

voxel_dim_dst = [options.pixel_spacing options.pixel_spacing options.slice_thickness];
dim = size(img3din);

y0 = ([1:dim(1)]-1)*voxel_dim_src(1);
x0 = ([1:dim(2)]-1)*voxel_dim_src(2);
z0 = ([1:dim(3)]-1)*voxel_dim_src(3);

% compute the region that image intensity is not 0, we will do
% interpolation only for this smaller region in order to speed up

imgy = max(max(img3din,[],3),[],2);
imgx = squeeze(max(max(img3din,[],3),[],1));
imgz = squeeze(max(max(img3din,[],1),[],2));
ymin = find(imgy>0,1,'first');
ymax = find(imgy>0,1,'last');
xmin = find(imgx>0,1,'first');
xmax = find(imgx>0,1,'last');
zmin = find(imgz>0,1,'first');
zmax = find(imgz>0,1,'last');

if zmin == zmax
	zmin = max(1,zmin-1);
	zmax = min(length(imgz),zmax+1);
end

y1 = 0:voxel_dim_dst(1):max(y0);
x1 = 0:voxel_dim_dst(2):max(x0);
z1 = 0:voxel_dim_dst(3):max(z0);

y0 = y0(ymin:ymax);
x0 = x0(xmin:xmax);
z0 = z0(zmin:zmax);
img3din = img3din(ymin:ymax,xmin:xmax,zmin:zmax);

img3dout = zeros([length(y1) length(x1) length(z1)],class(img3din));

extval = 0;
if sum(isnan(img3din(:))) > 100
	extval = nan;
end

[xx,yy,zz] = meshgrid(x1,y1,z1);
img3dout = interp3wrapper(x0,y0,z0,single(img3din),xx,yy,zz,options.interpolation_method,extval);

return;


function out = interp3_faster(x0,y0,z0,imgin,xx,yy,zz,method,val)
xx2 = squeeze(xx(1,:,1));
yy2 = squeeze(yy(:,1,1));
zz2 = squeeze(zz(1,1,:));

xs = xx2>=min(x0) & xx2 <= max(x0);
ys = yy2>=min(y0) & yy2 <= max(y0);
zs = zz2>=min(z0) & zz2 <= max(z0);

xs2 = find(xs>0,1,'first') : find(xs>0,1,'last');
ys2 = find(ys>0,1,'first') : find(ys>0,1,'last');
zs2 = find(zs>0,1,'first') : find(zs>0,1,'last');

out = ones(size(xx))*val;

if z0(1) > z0(2)
	z0minidx = find(z0>=max(zz2),1,'last');
	z0maxidx = find(z0<=min(zz2),1,'first');
else
	z0minidx = find(z0<=min(zz2),1,'last');
	z0maxidx = find(z0>=max(zz2),1,'first');
end


temp = interp3(x0,y0,z0(z0minidx:z0maxidx),imgin(:,:,z0minidx:z0maxidx),xx(ys2,xs2,zs2),yy(ys2,xs2,zs2),zz(ys2,xs2,zs2),method,val);

out(ys2,xs2,zs2) = temp;

return;


