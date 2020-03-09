function   [Px, Px0] =  Get_PG( im,win, ps ,nlsp,step,delta)

[h, w, ch]=  size(im);
S         =  win;
maxr      =  h-ps+1;
maxc      =  w-ps+1;
r         =  [1:step:maxr];
r         =  [r r(end)+1:maxr];
c         =  [1:step:maxc];
c         =  [c c(end)+1:maxc];
X = zeros(ps^2*ch,maxr*maxc,'single');
Px0 = [];
Px = [];
%% we usually not use this branch
if nlsp ==1
    k    =  0;
    for c = 1:ch
        for i = 1:ps
            for j  = 1:ps
                k    =  k+1;
                blk     =  im(r-1+i,c-1+j,c);
                Px(k,:) =  blk(:)';
            end
        end
    end
else
%% if nlsp !=1
    k    =  0;
    for c = 1:ch
        for i  = 1:ps
            for j  = 1:ps
                k    =  k+1;
                blk  =  im(i:end-ps+i,j:end-ps+j,c);
                X(k,:) =  blk(:)';
            end
        end
    end
    % Index image
    Index     =   (1:maxr*maxc);
    Index    =   reshape(Index, maxr, maxc);
    N1    =   length(r);
    M1    =   length(c);
    blk_arr   =  zeros(nlsp, N1*M1 );
    for  i  =  1 :N1
        for  j  =  1 : M1
            row     =   r(i);%3
            col     =   c(j);%1
            off     =  (col-1)*maxr + row;%the one dimentional index of full
            %picture 
            off1    =  (j-1)*N1 + i;
            %the one dimentional index of small picture
            % we select the patch in a window, but some times the window
            % will surpass the boundary of picture
            rmin    =   max( row-S, 1 );
            rmax    =   min( row+S, maxr );
            cmin    =   max( col-S, 1 );
            cmax    =   min( col+S, maxc );
            %
            idx     =   Index(rmin:rmax, cmin:cmax);
            idx     =   idx(:);%reshape it to a column vector
            neighbor       =   X(:,idx);% 
            %% count distance 
            seed       =   X(:,off);
            dis     =   (neighbor(1,:) - seed(1)).^2;
            for k = 2:ps^2
                dis   =  dis + (neighbor(k,:) - seed(k)).^2;
            end
            dis = dis./ps^2;
            %% sort it and return (nlsp) patchs
            [~,ind]   =  sort(dis);
            indc        =  idx( ind( 1 : nlsp ) );% extract the index of  top (nlsp) patch
            blk_arr(:,off1)  =  indc;% store index
            X_nl = X(:,indc); % or X_nl = neighbor(:,ind( 1 : nlsp ));
            % Removes DC component from image patch group
            DC = mean(X_nl,2);
            X_nl = bsxfun(@minus, X_nl, DC);
            % Select the smooth patches
            sv=var(X_nl);
            if max(sv) <= delta
                Px0 = [Px0 X_nl];
            else
                Px = [Px X_nl];
            end
        end
    end
end