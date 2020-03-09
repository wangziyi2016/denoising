function [mvy,mvx,mvz]=optical_flow_affine(im1,im2)
%
% Local affine transformation
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

dim = size(im1);
x0 = single([1:dim(2)]);
y0 = single([1:dim(1)]);
z0 = single([1:dim(3)]);
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

mvx = zeros(dim,'single');
mvy = zeros(dim,'single');
mvz = zeros(dim,'single');

H = waitbar(0,'Levelset motion');
set(H,'Name','Optical motion - local affine');
set(H,'NumberTitle','off');

waitbar(0,H,'Computing i1vxs ...');
i1vxs = lowpass3d(im1,1);
waitbar(0,H,'Computing gradient_ENO_3d');
[u,v,w,grad] = gradient_ENO_3d(i1vxs,'ENO1');

F = (im2 - im1);
grad = (grad + (grad==0)).^2;
%grad = (grad + (grad==0));
d_mvx = F .* u ./ grad;
d_mvy = F .* v ./ grad;
d_mvz = F .* w ./ grad;

mv = d_mvx.^2+d_mvy.^2+d_mvz.^2;
d_mvz(mv>1) = d_mvx(mv>1)./mv(mv>1);
d_mvy(mv>1) = d_mvy(mv>1)./mv(mv>1);
d_mvz(mv>1) = d_mvz(mv>1)./mv(mv>1);

Ws = single([0.0625 0.25 0.375 0.25 0.0625]);
W = ones(5,5,5,'single');
for k=1:5
	W(k,:,:) = W(k,:,:) * Ws(k);
	W(:,k,:) = W(:,k,:) * Ws(k);
	W(:,:,k) = W(:,:,k) * Ws(k);
end


clear u v w grad F i1vxs;

% Local affine approximation

for ntr = 1:dim(3)
	waitbar((ntr-1)/dim(3),H,sprintf('%d of %d: Local affine approximating ...', ntr, dim(3)));

	T = [ntr-2:ntr+2];
	T = max(1,T);
	T = min(dim(3),T);

	for nco = 1:dim(2)
		C = [nco-2:nco+2];
		C = max(1,C);
		C = min(dim(2),C);

		for nsa = 1:dim(1)
			S = [nsa-2:nsa+2];
			S = max(1,S);
			S = min(dim(1),S);

			dbx = d_mvx(S,C,T);
			dby = d_mvy(S,C,T);
			dbz = d_mvz(S,C,T);
			xx2 = xx(S,C,T).*W;
			yy2 = yy(S,C,T).*W;
			zz2 = zz(S,C,T).*W;

			[G,dbx2,dby2,dbz2]=affine_fit_3d(dbx,dby,dbz,xx2,yy2,zz2);
			mvx(nsa,nco,ntr) = -dbx2(3,3,3);
			mvy(nsa,nco,ntr) = -dby2(3,3,3);
			mvz(nsa,nco,ntr) = -dbz2(3,3,3);

% 			mvx(nsa,nco,ntr) = -mean(dbx(:));
% 			mvy(nsa,nco,ntr) = -mean(dby(:));
% 			mvz(nsa,nco,ntr) = -mean(dbz(:));
		end
	end
end

close(H);


