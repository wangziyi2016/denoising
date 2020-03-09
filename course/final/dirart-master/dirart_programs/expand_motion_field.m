function [mvy2,mvx2,mvz2]=expand_motion_field(mvy,mvx,mvz,newdim,offsets,boundary_size)
%{

[mvy2,mvx2,mvz2]=expand_motion_field(mvy,mvx,mvz,newdim,offsets,boundary_size)

If boundary_size is given, the enlarged motion fields will vanish within
the boundary


Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

if length(offsets) == 1
	offsets = [0 0 offsets];
end

dim = mysize(mvy);
ub = dim+offsets;

ys = 1:newdim(1); ys2 = ys-offsets(1); ys2(ys2<1) = 1; ys2(ys2>dim(1)) = dim(1);
xs = 1:newdim(2); xs2 = xs-offsets(2); xs2(xs2<1) = 1; xs2(xs2>dim(2)) = dim(2);
zs = 1:newdim(3); zs2 = zs-offsets(3); zs2(zs2<1) = 1; zs2(zs2>dim(3)) = dim(3);

mvy2=zeros(newdim,class(mvy));
mvx2 = mvy2;
mvz2 = mvy2;

mvy2(ys,xs,zs) = mvy(ys2,xs2,zs2);
mvx2(ys,xs,zs) = mvx(ys2,xs2,zs2);
mvz2(ys,xs,zs) = mvz(ys2,xs2,zs2);


if exist('boundary_size','var')
	if length(boundary_size) == 1
		boundary_size = [1 1 1]*boundary_size;
	end
	
	% Simulating motion field vanishing
	distx = 1:newdim(2);
	distx = max(distx - offsets(2) - dim(2),0);
	distx(1:offsets(2)) = offsets(2):-1:1;
	distx = min(distx,boundary_size(2));
	factorx = 1 - distx / boundary_size(2);
	
	for k = 1:newdim(2)
		if factorx(k) < 1
			mvy2(:,k,:) = mvy2(:,k,:) * factorx(k);
			mvx2(:,k,:) = mvx2(:,k,:) * factorx(k);
			mvz2(:,k,:) = mvz2(:,k,:) * factorx(k);
		end
	end
	
	disty = 1:newdim(1);
	disty = max(disty - offsets(1) - dim(1),0);
	disty(1:offsets(1)) = offsets(1):-1:1;
	disty = min(disty,boundary_size(1));
	factory = 1 - disty / boundary_size(1);
	
	for k = 1:newdim(1)
		if factory(k) < 1
			mvx2(k,:,:) = mvx2(k,:,:) * factory(k);
			mvy2(k,:,:) = mvy2(k,:,:) * factory(k);
			mvz2(k,:,:) = mvz2(k,:,:) * factory(k);
		end
	end

	distz = 1:newdim(3);
	distz = max(distz - offsets(3) - dim(3),0);
	distz(1:offsets(3)) = offsets(3):-1:1;
	distz = min(distz,boundary_size(3));
	factorz = 1 - distz / boundary_size(3);
	
	for k = 1:newdim(3)
		if factorz(k) < 1
			mvx2(:,:,k) = mvx2(:,:,k) * factorz(k);
			mvy2(:,:,k) = mvy2(:,:,k) * factorz(k);
			mvz2(:,:,k) = mvz2(:,:,k) * factorz(k);
		end
	end
	
end


