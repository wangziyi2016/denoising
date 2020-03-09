function newimg = move3dimage(img,Vy,Vx,Vz,method,offsets,modulation,boundary)
%
% Calculate the moved image: 
%    newimg = move3dimage3(img,Vy,Vx,Vz,method = 'linear',offsets = [0 0 0],modulation = 0,boundary='limit')
%
% Input: 
%	Vy, Vx, Vz	- the motion field
%	method		- interpolation method, default value is 'linear'
%   offsets		- Offsets of the motion field dimension respective to
%				  the img dimension
%   modulation  = 0, no modulation
%				  1, Jacobian modulation
%				  2, total density preservation modulation
%   boundary    = 'free','limit'
%
% In version 3, the input method is allowed to be larger than the dimension
% of motion fields. This actually allows better recostruction of the moved
% images because the motion fields could extend larger than the original
% dimension. An additional parameter has been added, the 'offsets'
% parameter.
% 
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('method','var') || isempty(method)
	method = 'linear';
% 	method = 'cubic';
end

if ~exist('offsets','var') || isempty(offsets)
	offsets = [0 0 0];
elseif length(offsets) == 1
	offsets = [0 0 offsets];
end

if ~exist('modulation','var') || isempty(modulation)
	modulation = 0;
end

if ~exist('boundary','var') || isempty(boundary)
	boundary = 'limit';
end

% defval = 0;	% Value to use for exterpolation
% if sum(isnan(img(:))) > 0
	defval = nan;
% end

imgclass = class(img);
img = single(img);

dimimg = mysize(img);
dimmotion = mysize(Vy);

% Computer Jacobian
if modulation == 1
	% Apply Jacobin intensity modulation
	disp('Intensity correction ...');
	jac = compute_jacobian(Vy,Vx,Vz);
	jac(isinf(jac)) = 1;
	jac(jac<0) = 1;
	factor = jac;
elseif modulation == 2
	% total density preservation modulation
	disp('Intensity correction ...');
% 	factor = compute_density_preservation_modulation_factor(Vy,Vx,Vz,smoothing1,smoothing2);
	factor = compute_density_preservation_modulation_factor(Vy,Vx,Vz,2,2);
end

x0 = single(1:dimmotion(2))+offsets(2);
y0 = single(1:dimmotion(1))+offsets(1);
z0 = single(1:dimmotion(3))+offsets(3);

if length(z0) <= 20
    [xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

    Vy = yy-Vy; clear yy;
    Vx = xx-Vx; clear xx;
    if ndims(img) > 2
        Vz = zz-Vz; clear zz;
    end
else
    N = round(length(z0)/5);
    N2 = ceil(length(z0)/N);
    for k = 1:N2
        z0a = (1:N) + (k-1)*N;
        z0a = min(z0a,length(z0));
       
        [xx,yy,zz] = meshgrid(x0,y0,z0(z0a));	% xx, yy and zz are the original coordinates of image pixels

        Vy(:,:,z0a) = yy-Vy(:,:,z0a); clear yy;
        Vx(:,:,z0a) = xx-Vx(:,:,z0a); clear xx;
        if ndims(img) > 2
            Vz(:,:,z0a) = zz-Vz(:,:,z0a); clear zz;
        end
    end
end

% recheck the boundaries
switch boundary
    case 'limit'
        Vy = max(Vy,1); Vy = min(Vy,dimimg(1));
        Vx = max(Vx,1); Vx = min(Vx,dimimg(2));
        if dimimg(3) > 1
            Vz = max(Vz,1); Vz = min(Vz,dimimg(3));
        end
end

if dimimg(3) > 1
% 	newimg = zeros(dimmotion,'single');
% 	if offsets(3) == 0 && size(img,3) == size(Vy,3)
% 		spacing = 20;
% 		if mod(dimimg(3),spacing) == 1
% 			spacing = 19;
% 		end
% 		
% 		N = ceil(dimimg(3)/spacing);
% 		fprintf('Moving image');
% 		for k = 1:N
% 			fprintf('.');
% 			zmin = (k-1)*spacing+1;
% 			zmax = min(dimimg(3),k*spacing);
% 			zmin2 = floor(min(min(min(Vz(:,:,zmin:zmax)))));
% 			zmax2 = ceil(max(max(max(Vz(:,:,zmin:zmax)))));
% 			%newimg(:,:,zmin:zmax) = interp3(xx(:,:,zmin2:zmax2),yy(:,:,zmin2:zmax2),zz(:,:,zmin2:zmax2),img(:,:,zmin2:zmax2),Vx(:,:,zmin:zmax),Vy(:,:,zmin:zmax),Vz(:,:,zmin:zmax),method);
% 			newimg(:,:,zmin:zmax) = interp3(x0,y0,z0(zmin2:zmax2),img(:,:,zmin2:zmax2),Vx(:,:,zmin:zmax),Vy(:,:,zmin:zmax),Vz(:,:,zmin:zmax),method);            
% 		end
% 		fprintf('\n');
% 	else
		zmin = max(floor(min(Vz(:))),1);
		zmax = min(ceil(max(Vz(:))),size(img,3));

		xmin = max(floor(min(Vx(:))),1);
		xmax = min(ceil(max(Vx(:))),size(img,2));

		ymin = max(floor(min(Vy(:))),1);
		ymax = min(ceil(max(Vy(:))),size(img,1));

% 		newimg = interp3(xmin:xmax,ymin:ymax,zmin:zmax,img(ymin:ymax,xmin:xmax,zmin:zmax),Vx,Vy,Vz,method,0);
		newimg = interp3wrapper(xmin:xmax,ymin:ymax,zmin:zmax,img(ymin:ymax,xmin:xmax,zmin:zmax),Vx,Vy,Vz,method,defval);
% 	end
	%newimg = interp3(img,Vx,Vy,Vz,method,0);
else
	newimg = interp2(img,Vx,Vy,method,defval);
end

%newimg = interpn(img,yy-Vy,xx-Vx,zz-Vz,method,0);


% Computer Jacobian
if modulation > 0
	mask = newimg > 350;	% Modulation is only for lung CT
	factor(mask) = 1;
    factor = min(factor,1.5);
	newimg = newimg .* factor;
end

newimg = cast(newimg,imgclass);
