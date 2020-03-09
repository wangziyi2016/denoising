function [ivy,ivx,ivz,mask] = invert_motion_field(vy,vx,vz,outputdim,offsets)
%
% Usages:
% 1. [ivy,ivx,ivz] = invert_motion_field(vy,vx,vz)
% 2. [ivy,ivx,ivz,mask] = invert_motion_field(vy,vx,vz,outputdim,offsets)
%    mask returns the area where the inverted motion field is well defined.
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

originaldim = size(vy);

if nargin > 3 && ~isequal(size(vy),outputdim)
	[vy,vx,vz] = expand_motion_field(vy,vx,vz,outputdim,offsets);
end

dims = ndims(vy);

if dims == 2
	vy = cat(3,vy,vy,vy);
	vx = cat(3,vx,vx,vx);
	vz = cat(3,vz,vz,vz);
end

dimmotion = mysize(vy);
x0 = single(1:dimmotion(2));
y0 = single(1:dimmotion(1));
z0 = single(1:dimmotion(3));
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels
vx = xx-vx;
vy = yy-vy;
vz = zz-vz;
[ivy,ivx,ivz]=spm_invdef(vy,vx,vz,mysize(vy),eye(4),eye(4));
ivx = xx - ivx;
ivy = yy - ivy;
ivz = zz - ivz;

if dims == 2
	ivx = ivx(:,:,2);
	ivy = ivy(:,:,2);
	ivz = ivz(:,:,2);
end

if nargout > 3
	% need to creat the mask file
	mask = ones(size(vy));
	if nargin > 3 && ~isequal(size(vy),outputdim)
		mask = zeros(size(vy));
		mask1 = ones(originaldim);
		vys = offsets(1)+(1:originaldim(1)); 
		vxs = offsets(2)+(1:originaldim(2));
		vzs = offsets(3)+(1:originaldim(3));
		mask(vys,vxs,vzs) = mask1;
		mask = move3dimage(mask,vy,vx,vz);
	end
end

