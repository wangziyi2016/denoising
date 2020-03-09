function [V1,V2,V3] = optical_flow_lkt_0(img1,imgt,ratio)
%
% The original LKT LMS method
% Reference:
%    D. Lucas and T. Kanade “An Iterative Image Registration Technique with an Application to Stereo Vision,” Proceedings of the 7th International Joint Conference on Artificial Intelligence 674-679 (1981)
%
% By: Deshan Yang, 09/2006
%
% Input parameters:
% img1	-	Image to be registered
% imgt	-	The target image (the reference)
%
% Outputs:
% u,v,w	-	The motion fields
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('ratio','var')
	ratio = [1 1 1];
end

dim=min(size(img1),size(imgt));
Ws = single([0.0625 0.25 0.375 0.25 0.0625]);
if dim(3) == 1
	W = ones(5,5,1,'single');
	for k=1:5
		W(k,:,:) = W(k,:,:) * Ws(k);
		W(:,k,:) = W(:,k,:) * Ws(k);
	end
else
	W = ones(5,5,5,'single');
	for k=1:5
		W(k,:,:) = W(k,:,:) * Ws(k);
		W(:,k,:) = W(:,k,:) * Ws(k);
		W(:,:,k) = W(:,:,k) * Ws(k);
	end
end
W2 = W.*W;

It = single(imgt) - single(img1);
[Iy,Ix,Iz] = gradient_3d_by_mask(single(img1));
Iy=Iy/ratio(1);
Ix=Ix/ratio(2);
Iz=Iz/ratio(3);

Vx = zeros(dim,'single'); Vz = Vx; Vy = Vx;
eigs = zeros([dim 3],'single');
eigvs = zeros([dim 9],'single');

H = waitbar(0,'Computing Matrix parameter A11');
set(H,'Name','Optical Flow by Lucas-Kanade');
set(H,'NumberTitle','off');

A11 = conv3dmask(Iy.*Iy,W2);
waitbar(1/12,H,'Computing Matrix parameter A12');
A12 = conv3dmask(Iy.*Ix,W2);
waitbar(2/12,H,'Computing Matrix parameter A13');
A13 = conv3dmask(Iy.*Iz,W2);
waitbar(3/12,H,'Computing Matrix parameter A21');
A21 = A12;
waitbar(4/12,H,'Computing Matrix parameter A22');
A22 = conv3dmask(Ix.*Ix,W2);
waitbar(5/12,H,'Computing Matrix parameter A23');
A23 = conv3dmask(Ix.*Iz,W2);
waitbar(6/12,H,'Computing Matrix parameter A31');
A31 = A13;
waitbar(7/12,H,'Computing Matrix parameter A32');
A32 = A23;
waitbar(8/12,H,'Computing Matrix parameter A33');
A33 = conv3dmask(Iz.*Iz,W2);

waitbar(9/12,H,'Computing Matrix parameter B1');
B1 = -conv3dmask(Iy.*It,W2);
waitbar(10/12,H,'Computing Matrix parameter B2');
B2 = -conv3dmask(Ix.*It,W2);
waitbar(11/12,H,'Computing Matrix parameter B3');
B3 = -conv3dmask(Iz.*It,W2);

waitbar(0,H,'Computing matrix det ...');
detA = A11.*A22.*A33-A11.*A23.*A32-A21.*A12.*A33+A21.*A13.*A32+A31.*A12.*A23-A31.*A13.*A22;
detA0 = detA + (detA==0);

waitbar(0,H,'Computing invert matrix ...');
invA11 = ( A22.*A33-A23.*A32) ./ detA0;
invA12 = (-A12.*A33+A13.*A32) ./ detA0;
invA13 = ( A12.*A23-A13.*A22) ./ detA0;
%invA21 = (-A21.*A33+A23.*A31) ./ detA0;
invA21 = invA12;
invA22 = ( A11.*A33-A13.*A31) ./ detA0;
invA23 = (-A11.*A23+A13.*A21) ./ detA0;
%invA31 = ( A21.*A32-A22.*A31) ./ detA0;
%invA32 = (-A11.*A32+A12.*A31) ./ detA0;
invA31 = invA13;
invA32 = invA23;
invA33 = ( A11.*A22-A12.*A21) ./ detA0;

waitbar(0,H,'Computing motion vectors ...');
V1 = invA11.*B1 + invA12.*B2 + invA13.*B3;
V2 = invA21.*B1 + invA22.*B2 + invA23.*B3;
V3 = invA31.*B1 + invA32.*B2 + invA33.*B3;

% E1=zeros(dim,'single');
% E2 = E1; E3 = E1;
% EV11 = E1; EV12 = E1; EV13 = E1;
% EV21 = E1; EV22 = E1; EV23 = E1;
% EV31 = E1; EV32 = E1; EV33 = E1;
% 
% total = dim(2)*dim(3);
% for i=1:dim(1)
% 	waitbar(i/dim(1),H,sprintf('Computing eigenvalues and eigenvectors: %d off %d',(i-1),dim(1)));
% 	for j=1:dim(2)
% 		for k=1:dim(3)
% 			A = [	A11(i,j,k) A12(i,j,k) A13(i,j,k);...
% 					A21(i,j,k) A22(i,j,k) A23(i,j,k);...
% 					A31(i,j,k) A32(i,j,k) A33(i,j,k)];
% 			[V,D] = eig(A);
% 			%eigs(i,j,k,:) = D(:);
% 			E1(i,j,k) = D(1,1);
% 			E2(i,j,k) = D(2,2);
% 			E3(i,j,k) = D(3,3);
% 			
% 			%eigvs(i,j,k,:) = V(:);
% 			EV11(i,j,k) = V(1,1);
% 			EV12(i,j,k) = V(2,1);
% 			EV13(i,j,k) = V(3,1);
% 			EV21(i,j,k) = V(1,2);
% 			EV22(i,j,k) = V(2,2);
% 			EV23(i,j,k) = V(3,2);
% 			EV31(i,j,k) = V(1,3);
% 			EV32(i,j,k) = V(2,3);
% 			EV33(i,j,k) = V(3,3);
% 		end
% 	end
% end
% maxe = max([E1(:);E2(:);E3(:)]);
% thres = maxe / thresholdratio;
% 
% waitbar(0,H,'Computing projection onto eigenvectors ...');
% P1 = V1.*EV11 + V2.*EV12 + V3.*EV13;
% P2 = V1.*EV21 + V2.*EV22 + V3.*EV23;
% P3 = V1.*EV31 + V2.*EV32 + V3.*EV33;
% 
% waitbar(0,H,'Checking small eigenvalues ...');
% P1(E1<thres)=0;
% P2(E2<thres)=0;
% P3(E3<thres)=0;
% 
% waitbar(0,H,'Recreating motion vectors from eigenvectors ...');
% V1 = P1.*EV11 + P2.*EV21 + P3.*EV31;
% V2 = P1.*EV12 + P2.*EV22 + P3.*EV32;
% V3 = P1.*EV13 + P2.*EV23 + P3.*EV33;

% waitbar(0,H,'Smoothing the motion fields ...');
% V1 = lowpass3d(V1,2);
% V2 = lowpass3d(V2,2);
% V3 = lowpass3d(V3,2);

close(H);
drawnow;
pause(0.1);

%clear A11 A12 A13 A21 A22 A23 A31 A32 A33 B1 B2 B3;

