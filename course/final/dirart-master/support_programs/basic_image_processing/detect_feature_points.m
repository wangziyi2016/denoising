function [mask,E1,E2,E3] = detect_feature_points(img,thresholdratios)
% [points,mask] = detect_feature_points(img,threshold)

dim=mysize(img);

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

[Iy,Ix,Iz] = gradient_3d_by_mask(single(img));

fprintf('Computing Matrix parameters:');

fprintf('A11');
A11 = conv3dmask(Iy.*Iy,W2);
fprintf(', A12');
A12 = conv3dmask(Iy.*Ix,W2);
fprintf(', A22');
A22 = conv3dmask(Ix.*Ix,W2);
if ndims(img) == 3
	fprintf(', A13');
	A13 = conv3dmask(Iy.*Iz,W2);
	fprintf(', A23');
	A23 = conv3dmask(Ix.*Iz,W2);
	fprintf(', A33');
	A33 = conv3dmask(Iz.*Iz,W2);
else
	A13 = zeros(size(A11),'single');
	A23 = A13;
	A33 = ones(size(A11),'single');
end
fprintf('\n');

A21 = A12;
A31 = A13;
A32 = A23;

E1=zeros(dim,'single');
E2 = E1; E3 = E1;

tic;
fprintf('Computing eigenvalues and eigenvectors:\n');
AA = zeros(3,3,1,dim(2),dim(3));
for i=1:dim(1)
	if mod(i,10) == 1
		fprintf('.');
	end
	AA(1,1,:,:,:) = A11(i,:,:);
	AA(1,2,:,:,:) = A12(i,:,:);
	AA(2,1,:,:,:) = A21(i,:,:);
	AA(2,2,:,:,:) = A22(i,:,:);
	if ndims(img) == 3
		AA(1,3,:,:,:) = A13(i,:,:);
		AA(2,3,:,:,:) = A23(i,:,:);
		AA(3,1,:,:,:) = A31(i,:,:);
		AA(3,2,:,:,:) = A32(i,:,:);
		AA(3,3,:,:,:) = A33(i,:,:);
	end

	[VN,DN] = ndfun('eig',AA);
	DN = real(DN);

	E1(i,:,:) = squeeze(DN(1,1,1,:,:));
	E2(i,:,:) = squeeze(DN(2,2,1,:,:));
	if ndims(img) == 3
		E3(i,:,:) = squeeze(DN(3,3,1,:,:));
	end
end
fprintf('\n');

clear A11 A12 A13 A21 A22 A23 A31 A32 A33 B1 B2 B3;

disp(sprintf('Eigen computation used %.2f seconds',toc));

mask = single(E1>max(E1(:))*thresholdratios(1)) + single(E2>max(E2(:))*thresholdratios(2)) + single(E3>max(E3(:))*thresholdratios(3));



