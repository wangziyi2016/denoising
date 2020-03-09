function out = interp3wrapper(x,y,z,v,xi,yi,zi,method,exterpval,limitelem)
%
% out = interp3wrapper(x,y,z,v,xi,yi,zi,method,exterpval,limitelem)
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(xi);
if ~exist('exterpval','var')
	exterpval = nan;
end

out = ones(dim,'single')*exterpval;
t = prod(dim);

if ndims(x) == 3
	% We don't need x y z to be a whole 3D matrix
	x = squeeze(x(1,:,1));
	y = squeeze(y(:,1,1));
	z = squeeze(z(1,1,:));
end

if( ~exist('method','var') || isempty(method) )
	method = 'linear';
end

if( ~exist('exterpval','var') || isempty(exterpval) )
	exterpval = 0;
end

if( ~exist('limitelem','var') || isempty(limitelem) )
	limitelem = 100*100*50;
end


% Check the directions of the input coordinates
if length(y)>1 && y(2)<y(1)
	y = fliplr(makeRowVector(y));
	v = flipdim(v,1);
end
if length(x)>1 && x(2)<x(1)
	x = fliplr(makeRowVector(x));
	v = flipdim(v,2);
end
if length(z)>1 && z(2)<z(1)
	z = fliplr(makeRowVector(z));
	v = flipdim(v,3);
end



if t <= limitelem || ndims(xi) == 2
	if exist('exterpval','var') && ~isempty(exterpval) 
		out = interp3(x,y,z,v,xi,yi,zi,method,exterpval);
	else
		out = interp3(x,y,z,v,xi,yi,zi,method);
	end
	return;
end

N = ceil( t / limitelem );
spacing = max(floor(dim(3)/N),2);
N = ceil(dim(3)/spacing);

%fprintf('Interp3wrapper ');
for k = 1:N
	%fprintf('.');
	zmin = (k-1)*spacing+1;
	zmax = min(dim(3),k*spacing);
	
	zmin2 = min(min(min(zi(:,:,zmin:zmax))));
	zmax2 = max(max(max(zi(:,:,zmin:zmax))));
	
	if isempty(find(z<zmax2)) || isempty(find(z>zmin2))
		continue;
	end
	
	zminidx = find(z<zmin2,1,'last'); 
	if isempty(zminidx)
 		zminidx = 1;
	end
	zmaxidx = find(z>zmax2,1,'first'); 
	if isempty(zmaxidx)
 		zmaxidx = length(z);
	end
	if zmaxidx == zminidx
		if zmaxidx >= length(z)
			zminidx = max(1,zminidx-1);
		else
			zmaxidx = min(length(z),zmaxidx+1);
		end
    end
	
    completely_outside = 0;
    
    xmin2 = min(min(min(xi(:,:,zmin:zmax))));
    xmax2 = max(max(max(xi(:,:,zmin:zmax))));
    if min(x)>xmax2 || max(x)<xmin2
        completely_outside = 1;
    end
    if x(1) < x(end)
        xminidx = find(x<xmin2,1,'last');
        if isempty(xminidx)
            xminidx = 1;
        end
        xmaxidx = find(x>xmax2,1,'first');
        if isempty(xmaxidx)
            xmaxidx = length(x);
        end
    else
        xminidx = find(x>xmax2,1,'last');
        if isempty(xminidx)
            xminidx = length(x);
        end
        xmaxidx = find(x<xmin2,1,'first');
        if isempty(xmaxidx)
            xmaxidx = 1;
        end
    end
	
    ymin2 = min(min(min(yi(:,:,zmin:zmax))));
    ymax2 = max(max(max(yi(:,:,zmin:zmax))));
    if min(y)>ymax2 || max(y)<ymin2
        completely_outside = 1;
    end
	if y(1)<y(end)
		yminidx = find(y<ymin2,1,'last');
		if isempty(yminidx)
			yminidx = 1;
		end
		ymaxidx = find(y>ymax2,1,'first');
		if isempty(ymaxidx)
			ymaxidx = length(y);
		end
	else
		ymin2 = min(min(min(yi(:,:,zmin:zmax))));
		ymax2 = max(max(max(yi(:,:,zmin:zmax))));
		yminidx = find(y>ymax2,1,'last');
		if isempty(yminidx)
			yminidx = length(y);
		end
		ymaxidx = find(y<ymin2,1,'first');
		if isempty(ymaxidx)
			ymaxidx = 1;
		end
    end
	
    if completely_outside == 0
        if exist('exterpval','var') && ~isempty(exterpval)
            out(:,:,zmin:zmax) = interp3(x(xminidx:xmaxidx),y(yminidx:ymaxidx),z(zminidx:zmaxidx),v(yminidx:ymaxidx,xminidx:xmaxidx,zminidx:zmaxidx),xi(:,:,zmin:zmax),yi(:,:,zmin:zmax),zi(:,:,zmin:zmax),method,exterpval);
        else
            out(:,:,zmin:zmax) = interp3(x(xminidx:xmaxidx),y(yminidx:ymaxidx),z(zminidx:zmaxidx),v(yminidx:ymaxidx,xminidx:xmaxidx,zminidx:zmaxidx),xi(:,:,zmin:zmax),yi(:,:,zmin:zmax),zi(:,:,zmin:zmax),method);
        end
    else
        if exist('exterpval','var') && ~isempty(exterpval)
            out(:,:,zmin:zmax) = exterpval;
        else
            out(:,:,zmin:zmax) = 0;
        end
    end
end
%fprintf('\n');


