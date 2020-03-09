function       [nDCnlX,blk_arr,DC,par] = Image2PG_II( im, par)
im = single(im);
% Pad noisy image to avoid Borader Issues
Paddedim = padarray(im,[par.Win,par.Win],'symmetric','both');
X = zeros(par.ps2, par.maxrcp, 'single');
k = 0;
for i = 1:par.ps
    for j = 1:par.ps
        k = k+1;
        blk = Paddedim(i:end-par.ps+i,j:end-par.ps+j);
        X(k,:) = blk(:)';
    end
end
% index of each patch in Pad image
Index = (1:par.maxrcp);
Index = reshape(Index,par.maxrp,par.maxcp);
% record the indexs of patches similar to the seed patch
blk_arr = zeros(par.nlsp, par.lenrc  ,'single');
% Patch Group Means
DC = zeros(par.ps2,par.lenrc ,'single');
% non-local patch groups
nDCnlX = zeros(par.ps2,par.lenrc *par.nlsp,'single');
% record the distance of compared patches to the reference patches
Vdis_rp = zeros((2*par.Win+1)^2, par.lenrc, 'single' );
% record the index of compared patches to the reference patches
Vidx_rp = Vdis_rp;
% Compute the Integral Image
v = Paddedim(1:par.h+par.Win,1:par.w+par.Win);
k = 0;
for dy = -par.Win:par.Win
    for dx = -par.Win:par.Win
        k = k + 1;
        % initial distance matrix in each iteration
        Mdis_rp = Inf*ones(par.lenr, par.lenc, 'single' );
        % Decide shift type, tx = vx+dx; ty = vy+dy
        t = zeros(size(v));
        if dx == 0 && dy == 0
            Midx_rp = Index(par.r+par.Win,par.c+par.Win);
            Vidx_rp(k,:) = Midx_rp(:);
            continue;
        elseif dx <= 0 && dy <= 0
            t(-dx+1:end,-dy+1:end) = v(1:end+dx,1:end+dy);
            a = 1-floor(dx/par.step);
            b = par.lenr;
            c = 1-floor(dy/par.step);
            d = par.lenc;
        elseif dx <= 0 && dy > 0
            t(-dx+1:end,1:end-dy) = v(1:end+dx,dy+1:end);
            ddy = (dy>1)*(2+ceil((dy-2)/par.step)) + (0<dy && dy<=1)*dy;
            a = 1 - floor(dx/par.step);
            b = par.lenr;
            c = 1;
            d = par.lenc - ddy;
        elseif dx > 0 && dy <= 0
            t(1:end-dx,-dy+1:end) = v(dx+1:end,1:end+dy);
            ddx = (dx>1)*(2+ceil((dx-2)/par.step)) + (0<dx && dx<=1)*dx;
            a = 1;
            b = par.lenr - ddx;
            c = 1-floor(dy/par.step);
            d = par.lenc;
        elseif dx > 0 && dy > 0
            t(1:end-dx,1:end-dy) = v(dx+1:end,dy+1:end);
            ddx = (dx>1)*(2+ceil((dx-2)/par.step)) + (0<dx && dx<=1)*dx;
            ddy = (dy>1)*(2+ceil((dy-2)/par.step)) + (0<dy && dy<=1)*dy;
            a = 1;
            b = par.lenr - ddx;
            c = 1;
            d = par.lenc - ddy;
        end
        % Create sqaured difference image
        diff = (v-t).^2;
        % Construct integral image along rows
        Sd = cumsum(diff,1);
        % Construct integral image along columns
        Sd = cumsum(Sd,2);
        % Obtaine the Square difference for each reference patches
        SqDist = Sd(par.x,par.y) + Sd(par.x0,par.y0) - Sd(par.x,par.y0) - Sd(par.x0,par.y);
        % Obtain the real value Square difference for suitable reference patches
        Mdis_rp( a:b,c:d ) = SqDist(a:b,c:d);
        % corresponding distance to reference patches
        Vdis_rp(k,:) = Mdis_rp(:);
        % corresponding index of compared patch to reference patches
        Midx_rp = Index(par.r+par.Win+dx,par.c+par.Win+dy);
        Vidx_rp(k,:) = Midx_rp(:);
    end
end
[~,Ind] = sort(Vdis_rp);
for i = 1:size(Vdis_rp,2)
    indc = Vidx_rp( Ind( 1:par.nlsp,i ),i );
    blk_arr(:,i) = indc;
    temp = X( : , indc );
    DC(:,i) = mean(temp,2);
    nDCnlX(:,(i-1)*par.nlsp+1:i*par.nlsp) = bsxfun(@minus,temp,DC(:,i));
end
blk_arr = par.maxr*(floor(blk_arr/par.maxrp)-par.Win) + mod(blk_arr,par.maxrp) - par.Win;