function [im_out, PSNR, SSIM ]   =  combined_Denoising2(  par_I,par_nim,nSig )
addpath Main_Utilities/Combined_Denoising

[par,model]   =   combined_setting( par_I,par_nim,nSig );
time0         =   clock;
nim           =   par.nim/255;
ori_im        =   par.I/255;
b             =   par.win;
[h,w,ch]     =   size(nim);

N             =   h-b+1;
M             =   w-b+1;
r             =   [1:N];
c             =   [1:M]; 
disp(sprintf('PSNR of the noisy image = %f \n', csnr(nim*255, ori_im*255, 0, 0) ));

im_out      =   nim;
lamada      =   par.w;
nsig        =   par.nSig/255;
cnt         =   1;
for iter = 1 : par.K        
    [blk_arr,wei_arr]    =   Block_matching( im_out, par);    
    
    for t = 1 : 1    
        %% estimate the variance of noisy
        im_out               =   im_out + lamada*(nim - im_out);
        dif                  =   im_out-nim;
        vd                   =   nsig^2-(mean(mean(dif.^2)));
        
        if (iter==1 && t==1)
            par.nSig  = sqrt(abs(vd));            
        else
            par.nSig  = sqrt(abs(vd))*par.lamada;
        end    
        sigma2I = par.nSig^2*ones(b^2,1);

        %% im_out to patch
        X         =   Im2Patch( im_out, par );    
        L         =   size(blk_arr,2); % the number of pg
        X_hat     =   zeros( size(X) );        
        W         =   zeros( size(X) );
        %% classification of pg and matching Dic
        % count the pg variance by weighed average
        
        for  i  =  1 : L
            B          =   X(:, blk_arr(:, i));            
            wei        =   wei_arr(:, i)';
            mB         =   sum(bsxfun(@times, B, wei),2);
            B          =   bsxfun(@minus, B, mB);               
        % match Dic
            if mod((iter-1)*3+t,1) == 0
                nPG = L; % number of PGs
                PYZ = zeros(model.nmodels,1);
                for j = 1:model.nmodels
                    sigma = model.covs(:,:,j) + diag(sigma2I);
                    [R,~] = chol(sigma);
                    Q = R'\B;
                    TempPYZ = - sum(log(diag(R))) - dot(Q,Q,1)/2;
                    PYZ(j) = sum(TempPYZ);
                end
                % find the most likely component for each patch group
                [~,dicidx] = max(PYZ);
                %dicidx
                tmp_X_hat   =   SSC_GSM( B,mB,dicidx,par  );
                X_hat(:, blk_arr(:,i))    =   X_hat(:, blk_arr(:,i)) + tmp_X_hat;
                W(:, blk_arr(:,i))     =   W(:, blk_arr(:,i)) + 1;

           end

        end       
    
    %% reconstruct im 
        im_out   =  zeros(h,w);
        im_wei   =  zeros(h,w);
        k        =   0;
      
        for i  = 1:b
            for j  = 1:b
                k    =  k+1;
                im_out(r-1+i,c-1+j)  =  im_out(r-1+i,c-1+j) + reshape( X_hat(k,:)', [N M]);
                im_wei(r-1+i,c-1+j)  =  im_wei(r-1+i,c-1+j) + reshape( W(k,:)', [N M]);
            end
        end
        im_out  =  im_out./(im_wei+eps);
    %% count psnr
        if isfield(par,'I')
            PSNR      =  csnr( im_out*255, ori_im*255, 0, 0 );
            SSIM      =  cal_ssim( im_out*255, ori_im*255, 0, 0 );
            %imwrite( im_out./255, 'Results\tmp.tif' );
        end
        
        fprintf( 'Iteration %d : nSig = %2.2f, PSNR = %2.2f, SSIM = %2.4f\n', cnt, par.nSig*255, PSNR, SSIM );
        cnt   =  cnt + 1;
    end       
end

if isfield(par,'I')
   PSNR      =  csnr( im_out*255, ori_im*255, 0, 0 );
   SSIM      =  cal_ssim( im_out*255, ori_im*255, 0, 0 );
end
disp(sprintf('Total elapsed time = %f min\n', (etime(clock,time0)/60) ));
im_out=im_out*255;
return;

function  [X W]   =   SSC_GSM( Y,mY,dicidx,par)
m                  =    size(Y,2);
% show 
c1=par.c1; 
c2=par.c2;
c3=par.c3;

nsig=par.nSig;%*255

% show me dic
U=par.D(:,:,dicidx);
%% alternative solving

Y                  =    Y(:,1:m);
A0                 =    U'*Y;
weighted=0;
if weighted==1
    S    = par.S(:,dicidx);
    %lambdaM = repmat(c3*ones(par.win^2,1)./(sqrt(S)+eps ),[1 length(idx)]);
    la=(c3*ones(par.win^2,1)./(sqrt(S)+eps ));
    theta0=2*nsig^2./la;
else

theta0             =    sqrt( sum(A0.^2, 2)/m );
theta0             =    sqrt( max( theta0.^2 - nsig^2, 0 ) );
end
B0                 =    (diag(1./(theta0+eps))*A0);

a                  =    sum(B0.^2, 2);
b                  =    -2*sum(B0.*A0, 2); 
c                  =    c1*nsig^2;
tmp                =    b.^2./(16*a.^2) - c./(2*a);
idx                =    tmp>=0;
tmp                =    sqrt( tmp(idx) );
a                  =    a(idx);
b                  =    b(idx);

f0                 =    c*log(eps);
t                  =    -b./(4*a);
t1                 =    t + tmp;
t2                 =    t - tmp;
f1                 =    a.*t1.^2 + b.*t1 + c*log(t1+eps);
f2                 =    a.*t2.^2 + b.*t2 + c*log(t2+eps);

ind                =    f2<f1;
f1(ind)            =    f2(ind);
t1(ind)            =    t2(ind);
ind                =    f0<f1;
t1(ind)            =    0;
theta              =    zeros( size(theta0) );
theta(idx)         =    t1;

t1                =    1./(theta.^2 + c2*nsig^2+eps);
B                 =    diag(t1)*diag(theta)'*A0;
X                 =    bsxfun(@plus, U*diag( theta)*B,mY );
W                 =   1;
return;
