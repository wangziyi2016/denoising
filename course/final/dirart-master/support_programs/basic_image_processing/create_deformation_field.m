function varargout = create_deformation_field(dim,maxmotions,motiontype)
%
%	[mvy,mvx] = create_deformation_field(dim,maxmotions,motiontype=1)
%	[mvy,mvx,mvz] = create_deformation_field(dim,maxmotions,motiontype=1)
%
% Motion type:	1 - linear motion
%				2 - ring motion
%				3 - sphere motion
%
%
maxmotions = maxmotions / 2;
mvx = ones(dim,'single');
mvy = mvx;

if (length(dim) > 2)
	mvz = mvx;
	[xx,yy,zz] = meshgrid(1:dim(2),1:dim(1),1:dim(3));
else
	[xx,yy] = meshgrid(1:dim(2),1:dim(1));
end


% Linear motion
fx = sin(xx / dim(2) * 4*pi)*maxmotions(2) .* sinc(yy/dim(1)*2-1);
fy = sin(yy / dim(1) * 4*pi)*maxmotions(1) .* sinc(xx/dim(2)*2-1);
mvx = mvx.*fx;
mvy = mvy.*fy;


varargout{1} = mvy;
varargout{2} = mvx;
if (length(dim) > 2)
	fz = sin(zz / dim(3) * 4*pi)*maxmotions(3);
	mvz = mvz.*fz;
	varargout{3} = mvz;
end


% Ring motion

% Sphere motion


