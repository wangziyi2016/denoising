function [ua,va,wa]=hs_velocity_avg3d(u,v,w,masks)
%{
% compute the average velocities in nbh of size WxWxW
% no weighting?! add it? cross/pus?
%
% [ua,va,wa]=hs_velocity_avg3d(u,v,w,masks)
%

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
and Issam El Naqa, elnaqa@radonc.wustl.edu

10/10/2007
Department of radiation oncology
Washington University in Saint Louis

%}

u = single(u);
v = single(v);
w = single(w);

% global dirart_2_use_gpu;
dirart_2_use_gpu = 0;
% if isempty(dirart_2_use_gpu)
% 	if exist('GPUDeviceCount','file') && GPUDeviceCount>0
% 		dirart_2_use_gpu = 1;
% 	else
% 		dirart_2_use_gpu = 0;
% 	end
% end


[M,N,L]=size(u);
WS=3; % 27th neighborhood...

% Lxy = floor(WS/2);
% vec=-Lxy:Lxy;
% 3D laplacian (2*6x+20=1)
if L == 1
	% 2D images
	W3 = 1/12*ones(WS,WS,1);
	W3(1,2,1)=1/6;W3(2,1,1)=1/6;W3(2,3,1)=1/6;W3(3,2,1)=1/6;
	W3(2,2,1)=0;
else
	W3=1/32*ones(WS,WS,WS);
	W3([1,3],2,2)=1/16; W3(2,[1,3],2)=1/16; W3(2,2,[1,3])=1/16;
	W3(2,2,2)=0;
end




mm = 1:M;
nn = 1:N;
kk = 1:L;

ua = zeros(size(u),'single');
if exist('masks','var')
	W3sum = ua;
end

va = ua;
wa = ua;

K=3; 
if (L==1) 
	K=1; % 2D images
end

use_convn = 1;

if ~exist('masks','var')
	if use_convn == 1
% 		ua=convnfft(u,W3,'same');
% 		va=convnfft(v,W3,'same');
% 		wa=convnfft(w,W3,'same');
		ua=convn(u,W3,'same');	% ok, convn is the fastest method for now
		va=convn(v,W3,'same');
		wa=convn(w,W3,'same');
% 		ua=conv3fft(u,W3);
% 		va=conv3fft(v,W3);
% 		wa=conv3fft(w,W3);
	elseif dirart_2_use_gpu > 0
		% To use GPU
% 		ugpu = GPUArray(u);
% 		vgpu = GPUArray(v);
% 		wgpu = GPUArray(w);
% 		uagpu = GPUArray(ua);
% 		vagpu = GPUArray(va);
% 		wagpu = GPUArray(wa);
% 		w3gpu = GPUArray(W3);
% 		for m = 1:3
% 			for n = 1:3
% 				for k = 1:K
% 					f = w3gpu(m,n,k);
% 					mm1 = mm + m - 2; mm1 = max(mm1,1); mm1 = min(mm1,M);
% 					nn1 = nn + n - 2; nn1 = max(nn1,1); nn1 = min(nn1,N);
% 					kk1 = kk + k - 2; kk1 = max(kk1,1); kk1 = min(kk1,L);
% 					uagpu = uagpu + ugpu(mm1,nn1,kk1)*f;
% 					vagpu = vagpu + vgpu(mm1,nn1,kk1)*f;
% 					wagpu = wagpu + wgpu(mm1,nn1,kk1)*f;
% 				end
% 			end
% 		end
		ua = hs_velocity_avg3d_1(u,K,mm,nn,kk);
		va = hs_velocity_avg3d_1(v,K,mm,nn,kk);
		wa = hs_velocity_avg3d_1(w,K,mm,nn,kk);
	else
		for m = 1:3
			for n = 1:3
				for k = 1:K
					f = W3(m,n,k);
					mm1 = mm + m - 2; mm1 = max(mm1,1); mm1 = min(mm1,M);
					nn1 = nn + n - 2; nn1 = max(nn1,1); nn1 = min(nn1,N);
					kk1 = kk + k - 2; kk1 = max(kk1,1); kk1 = min(kk1,L);
					ua = ua + u(mm1,nn1,kk1)*f;
					va = va + v(mm1,nn1,kk1)*f;
					wa = wa + w(mm1,nn1,kk1)*f;
				end
			end
		end
	end
else
	for m = 1:3
		for n = 1:3
			for k = 1:K
				mm1 = mm + m - 2; mm1 = max(mm1,1); mm1 = min(mm1,M);
				nn1 = nn + n - 2; nn1 = max(nn1,1); nn1 = min(nn1,N);
				kk1 = kk + k - 2; kk1 = max(kk1,1); kk1 = min(kk1,L);
				maskeq = single(masks(mm1,nn1,kk1)==masks);	% Check if the voxle is the same structure as the center voxel
				ua = ua + single(u(mm1,nn1,kk1))*W3(m,n,k).*maskeq;		% Averaging only with voxels of the same structure
				va = va + single(v(mm1,nn1,kk1))*W3(m,n,k).*maskeq;
				wa = wa + single(w(mm1,nn1,kk1))*W3(m,n,k).*maskeq;
				W3sum = W3sum + W3(m,n,k)*maskeq;
			end
		end
	end
	ua = ua./W3sum;
	va = va./W3sum;
	wa = wa./W3sum;
	
	if min(W3sum(:)) == 0
		ua(W3sum==0) = u(W3sum==0);
		va(W3sum==0) = v(W3sum==0);
		wa(W3sum==0) = w(W3sum==0);
	end

end

if ~isfloat(u)
	ua = cast(ua,class(u));
	va = cast(va,class(u));
	wa = cast(wa,class(u));
end

end

function vara = hs_velocity_avg3d_1(var,K,mm,nn,kk)

W3=ones(3,3,3);
W3([1,3],2,2)=2; W3(2,[1,3],2)=2; W3(2,2,[1,3])=2;
W3(2,2,2)=0;

[M,N,L]=size(var);
vargpu = gpuArray(var);
varagpu = vargpu*0;
for m = 1:3
	mm1 = mm + m - 2; mm1 = max(mm1,1); mm1 = min(mm1,M);
	for n = 1:3
		nn1 = nn + n - 2; nn1 = max(nn1,1); nn1 = min(nn1,N);
		for k = 1:K
			kk1 = kk + k - 2; kk1 = max(kk1,1); kk1 = min(kk1,L);
			f = W3(m,n,k);

			if f == 1
				tmpvargpu = vargpu(mm1,nn1,kk1);
				varagpu = varagpu + tmpvargpu;
			elseif f == 2
				tmpvargpu = vargpu(mm1,nn1,kk1);
				varagpu = varagpu + tmpvargpu + tmpvargpu;
			end
		end
	end
end

varagpu = varagpu / 32.0;
vara = gather(varagpu);

end


