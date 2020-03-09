function [V1,V2,V3] = optical_flow_lkt_6(method,img1,imgt,voxelsizes,thresholdratio,smooth_neighbor_flag,offsets,displayflag)
%
% optical flow using Lucas-Kanade algorithm
% Reference: 
%   D. Lucas and T. Kanade “An Iterative Image Registration Technique with an Application to Stereo Vision,” Proceedings of the 7th International Joint Conference on Artificial Intelligence 674-679 (1981)
%
% By: Deshan Yang, 09/2006
%
% Input parameters:
% img1	-	Image to be registered
% imgt	-	The target image (the reference)
% method  =		0	- Original LKT method
%				1	- Improved LKT method
%				2	- Original LKT method, with reverse consistency
%				3	- Improved LKT method, with reverse consistency
% voxelsizes -	Image voxel size ratio
% thresholdratio -	small eigen value threshold ratio
% smooth_neighbor_flag - apply smoothing on image gradient before LMS
% offsets -	Offsets of imgt inside img1
% displayflag - Enable debug information output
%
% Outputs:
% u,v,w	-	The motion fields
%
% Version 5 was updated from version 2.5
% In version 5, we are able to compute neighborhood gray level similarity
% and do faster on 3D convolution
%
% Version 6: Directional smoothing
%
% Version 7: reverse consistent
% 
%	method =	0:	original LKT method
%				1:	regular method (improved)
%				2:	reverse consistent
%				3:	reverse consistent (improved)
%
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if ~exist('thresholdratio','var')
	thresholdratio = 1000;
end

if( ~exist('voxelsizes','var') )
	voxelsizes = [1 1 1];
elseif length(voxelsizes) == 1
	voxelsizes = [1 1 voxelsizes];
end

if( ~exist('smooth_neighbor_flag','var') || isempty(smooth_neighbor_flag) )
	smooth_neighbor_flag = 1;
end

if( ~exist('offsets','var') || isempty(offsets) )
	offsets = [0 0 0];
end

if( ~exist('displayflag','var') || isempty(displayflag) )
	displayflag = 1;
end



dim=mysize(imgt);

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

[Iy,Ix,Iz] = gradient_3d_by_mask(single(img1));

if method == 2 || method == 3
	[Iy2,Ix2,Iz2] = gradient_3d_by_mask(single(imgt));
	Iy = (Iy+Iy2); clear Iy2;
	Ix = (Ix+Ix2); clear Ix2;
	Iz = (Iz+Iz2); clear Iz2;
end

if size(img1,3) > size(imgt,3)
	img1 = img1((1:dim(1))+offsets(1),(1:dim(2))+offsets(2),(1:dim(3))+offsets(3));
	Iy = Iy((1:dim(1))+offsets(1),(1:dim(2))+offsets(2),(1:dim(3))+offsets(3));
	Ix = Ix((1:dim(1))+offsets(1),(1:dim(2))+offsets(2),(1:dim(3))+offsets(3));
	Iz = Iz((1:dim(1))+offsets(1),(1:dim(2))+offsets(2),(1:dim(3))+offsets(3));
end

Iy=Iy*voxelsizes(1);
Ix=Ix*voxelsizes(2);
Iz=Iz*voxelsizes(3);
It = single(imgt) - single(img1);

Vx = zeros(dim,'single'); Vz = Vx; Vy = Vx;
eigs = zeros([dim 3],'single');
eigvs = zeros([dim 9],'single');

fprintf('Computing Matrix parameters:');

if smooth_neighbor_flag == 0 || method == 0 || method == 2
	fprintf('A11');
	A11 = conv3dmask(Iy.*Iy,W2);
	fprintf(', A12');
	A12 = conv3dmask(Iy.*Ix,W2);
	fprintf(', A22');
	A22 = conv3dmask(Ix.*Ix,W2);
	fprintf(', B1');
	B1 = -conv3dmask(Iy.*It,W2);
	fprintf(', B2');
	B2 = -conv3dmask(Ix.*It,W2);
	if ndims(img1) == 3
		fprintf(', A13');
		A13 = conv3dmask(Iy.*Iz,W2);
		fprintf(', A23');
		A23 = conv3dmask(Ix.*Iz,W2);
		fprintf(', A33');
		A33 = conv3dmask(Iz.*Iz,W2);
		fprintf(', B3');
		B3 = -conv3dmask(Iz.*It,W2);
	else
		A13 = zeros(size(A11),'single');
		A23 = A13;
		A33 = ones(size(A11),'single');
		B3 = A13;
	end
else
	sigmas=compute_neighborhoold_sigma(img1,5);
	[A11,A12,A13,A22,A23,A33,B1,B2,B3] = smooth_neighborhoold9(img1,5,sigmas,1,0.5,Iy.*Iy,Iy.*Ix,Iy.*Iz,Ix.*Ix,Ix.*Iz,Iz.*Iz,-Iy.*It,-Ix.*It,-Iz.*It);
end
fprintf('\n');

A21 = A12;
A31 = A13;
A32 = A23;

fprintf('Computing matrix det ...\n');
if ndims(img1) == 3
	detA = A11.*A22.*A33-A11.*A23.*A32-A21.*A12.*A33+A21.*A13.*A32+A31.*A12.*A23-A31.*A13.*A22;
else
	detA = A11.*A22-A21.*A12;
end

detA0 = detA + (detA==0);

fprintf('Computing invert matrix ...\n');
if ndims(img1) == 3
	invA11 = ( A22.*A33-A23.*A32) ./ detA0;
	invA12 = (-A12.*A33+A13.*A32) ./ detA0;
	invA13 = ( A12.*A23-A13.*A22) ./ detA0;
	invA21 = invA12;
	invA22 = ( A11.*A33-A13.*A31) ./ detA0;
	invA23 = (-A11.*A23+A13.*A21) ./ detA0;
	invA31 = invA13;
	invA32 = invA23;
	invA33 = ( A11.*A22-A12.*A21) ./ detA0;
else
	invA11 = A22 ./ detA0;
	invA12 = -A12 ./ detA0;
	invA22 = A11 ./ detA0;
	invA21 = invA12;

	invA33 = A33;	% Ones
	invA13 = A13;	% Zero
	invA23 = A13;
	invA31 = A13;
	invA32 = A13;
end

fprintf('Computing motion vectors ...\n');
if ndims(img1) == 3
	V1 = invA11.*B1 + invA12.*B2 + invA13.*B3;
	V2 = invA21.*B1 + invA22.*B2 + invA23.*B3;
	V3 = invA31.*B1 + invA32.*B2 + invA33.*B3;
else
	V1 = invA11.*B1 + invA12.*B2;
	V2 = invA21.*B1 + invA22.*B2;
	V3 = zeros(size(img1),'single');;
end

if method == 1 || method == 3
	tic
	E1=zeros(dim,'single');
	E2 = E1; E3 = E1;
	EV11 = E1; EV12 = E1; EV13 = E1;
	EV21 = E1; EV22 = E1; EV23 = E1;
	EV31 = E1; EV32 = E1; EV33 = E1;

	fprintf('Computing eigenvalues and eigenvectors:\n');
	
	if isunix == 0
		AA = zeros(3,3,1,dim(2),dim(3));
	end
	
	for i=1:dim(1)
		if mod(i,10) == 1
			fprintf('.');
		end
% 		if isunix == 0
% 			AA(1,1,:,:,:) = A11(i,:,:);
% 			AA(1,2,:,:,:) = A12(i,:,:);
% 			AA(2,1,:,:,:) = A21(i,:,:);
% 			AA(2,2,:,:,:) = A22(i,:,:);
% 			if ndims(img1) == 3
% 				AA(1,3,:,:,:) = A13(i,:,:);
% 				AA(2,3,:,:,:) = A23(i,:,:);
% 				AA(3,1,:,:,:) = A31(i,:,:);
% 				AA(3,2,:,:,:) = A32(i,:,:);
% 				AA(3,3,:,:,:) = A33(i,:,:);
% 			end
% 
% 			[VN,DN] = ndfun('eig',AA);
% 			VN = real(VN);
% 			DN = real(DN);
% 			E1(i,:,:) = squeeze(DN(1,1,1,:,:));
% 			E2(i,:,:) = squeeze(DN(2,2,1,:,:));
% 
% 			EV11(i,:,:) = squeeze(VN(1,1,1,:,:));
% 			EV12(i,:,:) = squeeze(VN(2,1,1,:,:));
% 			EV21(i,:,:) = squeeze(VN(1,2,1,:,:));
% 			EV22(i,:,:) = squeeze(VN(2,2,1,:,:));
% 
% 			if ndims(img1) == 3
% 				E3(i,:,:) = squeeze(DN(3,3,1,:,:));
% 				EV13(i,:,:) = squeeze(VN(3,1,1,:,:));
% 				EV23(i,:,:) = squeeze(VN(3,2,1,:,:));
% 				EV31(i,:,:) = squeeze(VN(1,3,1,:,:));
% 				EV32(i,:,:) = squeeze(VN(2,3,1,:,:));
% 				EV33(i,:,:) = squeeze(VN(3,3,1,:,:));
% 			end
% 		else
			% For unix system
			for m = 1:dim(2)
				for n = 1:dim(3)
					if ndims(img1) == 3
						A = [A11(i,m,n) A12(i,m,n) A13(i,m,n); A21(i,m,n) A22(i,m,n) A23(i,m,n); A31(i,m,n) A32(i,m,n) A33(i,m,n)];
					else
						A = [A11(i,m,n) A12(i,m,n); A21(i,m,n) A22(i,m,n)];
					end
					[V,D] = eig(A);
					V = real(V);
					D = real(D);
					
					E1(i,m,n) = D(1,1);
					E2(i,m,n) = D(2,2);
					EV11(i,m,n) = V(1,1);
					EV12(i,m,n) = V(2,1);
					EV21(i,m,n) = V(1,2);
					EV22(i,m,n) = V(2,2);
					
					if ndims(img1) == 3
						E3(i,m,n) = D(3,3);
						EV13(i,m,n) = V(3,1);
						EV23(i,m,n) = V(3,2);
						EV31(i,m,n) = V(1,3);
						EV32(i,m,n) = V(2,3);
						EV33(i,m,n) = V(3,3);
					end
				end
			end
		end
% 	end
	clear AA;
	fprintf('\n');

	clear A11 A12 A13 A21 A22 A23 A31 A32 A33 B1 B2 B3;

	if ndims(img1) == 3
		maxe = max([E1(:);E2(:);E3(:)]);
	else
		maxe = max([E1(:);E2(:)]);
	end

	thres = maxe / thresholdratio;
	disp(sprintf('Eigen computation used %.2f seconds',toc));

	fprintf('Computing projection onto eigenvectors ...\n');
	if ndims(img1) == 3
		P1 = V1.*EV11 + V2.*EV12 + V3.*EV13;
		P2 = V1.*EV21 + V2.*EV22 + V3.*EV23;
		P3 = V1.*EV31 + V2.*EV32 + V3.*EV33;
	else
		P1 = V1.*EV11 + V2.*EV12;
		P2 = V1.*EV21 + V2.*EV22;
	end

	fprintf('Checking small eigenvalues ...\n');
	P1(E1<thres)=0;
	P2(E2<thres)=0;
	if ndims(img1) == 3
		P3(E3<thres)=0;
	end

	fprintf('Recreating motion vectors from eigenvectors ...\n');
	if ndims(img1) == 3
		V1 = P1.*EV11 + P2.*EV21 + P3.*EV31;
		V2 = P1.*EV12 + P2.*EV22 + P3.*EV32;
		V3 = P1.*EV13 + P2.*EV23 + P3.*EV33;
	else
		V1 = P1.*EV11 + P2.*EV21;
		V2 = P1.*EV12 + P2.*EV22;
		V3 = P1.*EV13 + P2.*EV23;
	end

	% waitbar(0,H,'Smoothing the motion fields ...');

	% if smooth_neighbor_flag == 0
	% 	V1 = lowpass3d(V1,2);
	% 	V2 = lowpass3d(V2,2);
	% 	V3 = lowpass3d(V3,2);
	% else
	% 	[V1,V2,V3] = smooth_neighborhoold3(img1,5,sigmas,1,0.5,V1,V2,V3);
	% end

	% Limit maximal motion
	absV = sqrt(V1.^2+V2.^2+V3.^2);
	maxm = 0.5;
	idxes = find(absV>maxm);
	V1(idxes) = V1(idxes)*0.5./absV(idxes);
	V2(idxes) = V2(idxes)*0.5./absV(idxes);
	V3(idxes) = V3(idxes)*0.5./absV(idxes);
	clear absV idxes;

	% Directional smoothing / directional diffusion
	% For voxels that have low eigenvalues on any of its eigenvector
	% directions, we will directional diffuse neighbore's motion to this voxel

	fprintf('Directionally smoothing the motion fields ...\n');
	V1s = lowpass3d(V1,6);
	V2s = lowpass3d(V2,6);
	if ndims(img1) == 3
		V3s = lowpass3d(V3,6);
	end

	% if ndims(img1) == 3
	% 	P1s = V1s.*EV11 + V2s.*EV12 + V3s.*EV13;
	% 	P2s = V1s.*EV21 + V2s.*EV22 + V3s.*EV23;
	% 	P3s = V1s.*EV31 + V2s.*EV32 + V3s.*EV33;
	% else
	% 	P1s = V1s.*EV11 + V2s.*EV12;
	% 	P2s = V1s.*EV21 + V2s.*EV22;
	% end

	t2 = 100;

	E1s = ((E1>=thres)&(E1<thres*t2)).*(t2*thres-E1)/thres/(t2-1) + E1<thres;
	E2s = ((E2>=thres)&(E2<thres*t2)).*(t2*thres-E2)/thres/(t2-1) + E2<thres;
	V1 = V1.*(1-E1s) + E1s.*V1s;
	V2 = V2.*(1-E2s) + E2s.*V2s;
	if ndims(img1) == 3
		E3s = ((E3>=thres)&(E3<thres*t2)).*(t2*thres-E3)/thres/(t2-1) + E3<thres;
		V3 = V3.*(1-E3s) + E3s.*V3s;
	end

	fprintf('Smoothing the motion fields ...\n');
	V1 = lowpass3d(V1,2);
	V2 = lowpass3d(V2,2);
	if ndims(img1) == 3
		V3 = lowpass3d(V3,2);
	end
end

%if (displayflag) 
%	close(H); 
%end
drawnow;
pause(0.1);


