function  [par,model]  =  self_setting( nSig, idx )
load('PG_GMM_9x9_win15_nlsp10_delta0.002_cls33.mat')
%load('PG_GMM_8x8_win15_nlsp10_delta0.002_cls33.mat')

par.nSig      =   nSig;
par.win = ps;        % patch size

K             =   6;%[3,  3,  3,  3, 4, 5];
par.K         =   K;%k(idx)
par.nblk      =   15;
%nblk selection 
%% buff
%nsig=100
%90 21.76
%10 22.04%
%30 21.85
%5 21.25
%% lenna
%10 25.03
%90 25.77
%% cameraman
%15 22.44
par.c1        =   2.1*sqrt(2);
par.c2        =   par.c1/4;
par.lamada    =   0.9;    % make the nsig smaller in each iteration .67
par.w         =   0.26;    % the rate of return .23
par.hp        =   95;
par.step      =   min(4, par.win-1);

for i = 1:size(GMM_D,2)
    par.D(:,:,i) = reshape(single(GMM_D(:, i)), size(GMM_S,1), size(GMM_S,1));
end
par.S = single(GMM_S);

end




