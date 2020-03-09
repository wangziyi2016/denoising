function varargout = ComputeStructureCenterPos(varargin)
%
% [y,x,z] = ComputeStructureCenterPos(handles,strnum)
% ... = ComputeStructureCenterPos(mask3d,ys,xs,zs)
% c = ComputeStructureCenterPos(...)
%
if nargin == 2
	handles = varargin{1};
	strnum = varargin{2};
	
	strdata = handles.ART.structures{strnum};
	if strdata.meshRep == 0
		% POI
		info = GetElement(handles.ART.structure_structInfos,strnum);
		y = (info.ymin+info.ymax)/2;
		x = (info.xmin+info.xmax)/2;
		z = (info.zmin+info.zmax)/2;
	else
		[mask3d,ys,xs,zs] = MakeStructureMask(handles.ART.structures{strnum});
	end
	
else
	mask3d = varargin{1};
	ys = varargin{2};
	xs = varargin{3};
	zs = varargin{4};
end

if exist('mask3d','var')
	% use the center of the structure (k-1)
	sumx = squeeze(sum(sum(mask3d,3),1));
	sumy = squeeze(sum(sum(mask3d,3),2))';
	sumz = squeeze(sum(sum(mask3d,2),1))';
	sumtotal = sum(mask3d(:));
	y = sum(sumy.*ys)/sumtotal;
	x = sum(sumx.*xs)/sumtotal;
	z = sum(sumz.*zs)/sumtotal;
end

if nargout == 1
	c(1) = y;
	c(2) = x;
	c(3) = z;
	varargout{1} = c;
else
	varargout{1} = y;
	varargout{2} = x;
	varargout{3} = z;
end


		