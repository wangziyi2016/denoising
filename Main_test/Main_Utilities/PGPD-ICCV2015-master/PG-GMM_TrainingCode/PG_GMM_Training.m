clear,clc;
TD_path = '/Users/wzy/Documents/MATLAB/IP/sc_denoise/clean_data_set';
%%% Set the hyper parameters
step    = 3;
delta   = 0.002;
win     = 30;
nlsp    = 10;% the nearest patch num (patch group size)
color = 'RGB'; % RGB or Gray
%%% read natural clean images
ext         =  {'*.jpg','*.jpeg','*.JPG','*.png','*.bmp'};
im_dir   =  [];
for i = 1 : length(ext)
    im_dir = cat(1,im_dir, dir(fullfile(TD_path,ext{i})));
end
im_num      =   length(im_dir);

for ps      = 5%[5 6 7 8 9]
    X     =  [];
    X0 = [];
    for  i  =  1:im_num
        if strcmp(color,'RGB')==1
            im = im2double(imread(fullfile(TD_path, im_dir(i).name)));
        elseif strcmp(color,'Gray')==1
            im = im2double(rgb2gray(imread(fullfile(TD_path, im_dir(i).name))));
        end
        
        [Px, Px0] = Get_PG( im,win,ps,nlsp,step,delta);
        [~, ~, ch]  =  size(im);%ch means channal
        clear im;
        X0 = [X0 Px0];
        X   = [X Px];
        %clear Px Px0;
    end
    %% EM 
    for cls_num = 16%[16 32 64 128 256 512 1024]
        % PG-GMM Training
        [model,llh,cls_idx] = emgm(X,cls_num,nlsp);
        [s_idx, seg]    =  Proc_cls_idx( cls_idx );
        cls_num = size(model.R,2)+1;
        model.R = []; % R is now useless
        model.means(:,cls_num) = mean(X0,2);
        model.covs(:,:,cls_num) = cov(X0');
        length0 = size(X0,2)/nlsp;
        model.mixweights = [model.mixweights length0/(length0 + length(cls_idx))]/(sum(model.mixweights) + length0/(length0 + length(cls_idx)));
        model.nmodels = model.nmodels + 1;
        % Get GMM dictionaries and regularization parameters
        GMM_D    =  zeros((ps^2*ch)^2, cls_num);
        GMM_S    =  zeros(ps^2*ch, cls_num);
        for  i  =  1 : length(seg)-1
            idx    =   s_idx(seg(i)+1:seg(i+1));
            cls    =   cls_idx(idx(1));
            [P,S,~] = svd(model.covs(:,:,i));
            S = diag(S);
            GMM_D(:,cls)    = P(:);
            GMM_S(:,cls)    = S;
        end
        [P0,S0,~] = svd(model.covs(:,:,cls_num));
        S0 = diag(S0);
        GMM_D(:,cls_num)    =  P0(:);
        GMM_S(:,cls_num)    =  S0;
        % save PG-GMM model
        name = sprintf('/Users/wzy/Documents/MATLAB/IP/sc_denoise/GMM_model/PG_GMM_%s_%dx%d_win%d_nlsp%d_delta%2.3f_cls%d.mat',color,ps,ps,win,nlsp,delta,cls_num);
        %save(name,'model','nlsp','GMM_D','GMM_S','cls_num','delta','ps','win');
    end
    %clear X0;
    %clear X;
end