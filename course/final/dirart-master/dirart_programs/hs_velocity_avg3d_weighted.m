function [ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,weighting_method,masks,fy,fx,fz)
%{
compute the average velocities in nbh of size WxWxW

[ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,1,[],   grad    )
[ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,2,[],   fx,fy,fz)
[ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,3,masks         )
[ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,4,masks,grad    )
[ua,va,wa]=hs_velocity_avg3d_weighted(u,v,w,5,masks,fx,fy,fz)

weighting_method =	0		no weighting
					1		weighting by overall gradient
					2		weighting for x, y, aand z by gradient in
							its own directions
					3		weighting by structure masks (piecewise
							smoothing)
					4		by overall gradient and structure masks
							(not implemented yet)
					5		by individual gradient and masks

Input:	masks		-	structure masks
			fy,fx,fz	-	gradient on y, x and z

Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

if weighting_method == 0
	[ua,va,wa]=hs_velocity_avg3d(u,v,w);
	return;
elseif weighting_method == 3
	[ua,va,wa]=hs_velocity_avg3d(u,v,w,masks);
	return;
elseif weighting_method == 1
	if exist('fx','var')
		grad = sqrt(fy.*fy+fx.*fx+fz.*fz);
	else
		grad = fy;
	end
else
	fy = abs(fy);
	fx = abs(fx);
	fz = abs(fz);
end

	
[M,N,L]=size(u);
WS=3; % 27th neighborhood...

Lxy = floor(WS/2);
vec=-Lxy:Lxy;
% 3D laplacian (2*6x+20=1)
if L == 1
	W3 = 1/12*ones(WS,WS,1);
	W3(1,2,1)=1/6;W3(2,1,1)=1/6;W3(2,3,1)=1/6;W3(3,2,1)=1/6;
	W3(2,2,1)=0;
else
	W3=1/32*ones(WS,WS,WS);
	W3([1,3],2,2)=1/16; W3(2,[1,3],2)=1/16; W3(2,2,[1,3])=1/16;
	W3(2,2,2)=0;
end


if weighting_method == 1
	grada = conv3dmask(grad,W3);
	grada = grada + (grada==0);
	ua = conv3dmask(u.*grad,W3)./grada;
	va = conv3dmask(v.*grad,W3)./grada;
	wa = conv3dmask(w.*grad,W3)./grada;
elseif weighting_method == 2
	fxa = conv3dmask(fx,W3); fxa = fxa + (fxa==0);
	fya = conv3dmask(fy,W3); fya = fya + (fya==0);
	fza = conv3dmask(fz,W3); fza = fza + (fza==0);
	ua = conv3dmask(u.*fy,W3)./fya;
	va = conv3dmask(v.*fx,W3)./fxa;
	wa = conv3dmask(w.*fz,W3)./fza;
else
	N = max(masks(:));
	N0 = min(masks(:));
	
	ua = u;
	va = v;
	wa = w;
	
	% smoothing for every individual structures
	for s = N0:N
		mask_st = (masks == s);
		if weighting_method == 4
			grad_st = grad.*mask_st;
			grada = conv3dmask(grad_st,W3);
			grada = grada + (grada==0);
			ua_st = conv3dmask(u.*grad_st,W3)./grada;
			va_st = conv3dmask(v.*grad_st,W3)./grada;
			wa_st = conv3dmask(w.*grad_st,W3)./grada;
		elseif weighting_method == 5
			fx_st = fx.*mask_st;
			fy_st = fy.*mask_st;
			fz_st = fz.*mask_st;
			
			fxa = conv3dmask(fx_st,W3); fxa = fxa + (fxa==0);
			fya = conv3dmask(fy_st,W3); fya = fya + (fya==0);
			fza = conv3dmask(fz_st,W3); fza = fza + (fza==0);
			ua_st = conv3dmask(u.*fy_st,W3)./fya;
			va_st = conv3dmask(v.*fx_st,W3)./fxa;
			wa_st = conv3dmask(w.*fz_st,W3)./fza;
		end
		
		ua(mask_st) = ua_st(mask_st);
		va(mask_st) = va_st(mask_st);
		wa(mask_st) = wa_st(mask_st);
	end
end


% mm = 1:M;
% nn = 1:N;
% kk = 1:L;
% 
% ua = zeros(size(u),'single');
% va = ua;
% wa = ua;
% 
% K=3; 
% if (L==1) 
% 	K=1; 
% end
% 
% for m = 1:3
% 	for n = 1:3
% 		for k = 1:K
% 			if weighting_method == 1
% 			else
% 				mm1 = mm + m - 2; mm1 = max(mm1,1); mm1 = min(mm1,M);
% 				nn1 = nn + n - 2; nn1 = max(nn1,1); nn1 = min(nn1,N);
% 				kk1 = kk + k - 2; kk1 = max(kk1,1); kk1 = min(kk1,L);
% 				ua = ua + single(u(mm1,nn1,kk1))*W3(m,n,k);
% 				va = va + single(v(mm1,nn1,kk1))*W3(m,n,k);
% 				wa = wa + single(w(mm1,nn1,kk1))*W3(m,n,k);
% 			end
% 		end
% 	end
% end
% 
%

if ~isfloat(u)
	ua = cast(ua,class(u));
	va = cast(va,class(u));
	wa = cast(wa,class(u));
end

return
