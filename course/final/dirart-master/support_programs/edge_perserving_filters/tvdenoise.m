function u = tvdenoise(f,lambda,NumSteps,u)
%TVDENOISE  Total variation image denoising
%   u = TVDENOISE(f,lambda,NumSteps) denoises the input image f over
%   NumSteps number of iterations.  The larger the parameter lambda, the
%   stronger the denoising.  The output u approximately minimizes the
%   Rudin-Osher-Fatemi (ROF) denoising model
%       || f - u ||^2_L^2  +  lambda*TV(u)
%   where TV(u) is the total variation of u.
%
%   TVDENOISE(...,u0) specifies the initial image u0.  By default, u0 = f.
%
%   Example: Run TVDENOISE without any inputs for a demo
%   >> tvdenoise

% Pascal Getreuer 2007

if nargin < 4
    if nargin == 0
        %%% Demo %%%
        
        % Generate image
        [x,y] = meshgrid(linspace(-1,1,250),linspace(-1,1,250));
        [th,r] = cart2pol(x,y);
        f = (sqrt(2)-r).^2.*(sin(12*r + 4*th) > 0 | r < 0.05)*255;
        f = conv2(f,ones(5)/25,'same');
        f = f(3:5:end,3:5:end);
        f = f + randn(size(f))*30;  % Add noise
        
        % Denoise the image with lambda=400 and 25 iterations
        v = tvdenoise(f,400,25);
        
        % Plots
        subplot(1,2,1);
        image(f);
        title('Noisy Image');
        axis image; axis off; colormap(gray(256));        
        subplot(1,2,2);
        image(v);
        title('Denoised Image');        
        axis image; axis off; colormap(gray(256));
        shg;
                
        return;
    end
    u = f;
elseif any(size(f) ~= size(u))
    error('u0 must have the same size as f.');
end

EpsSqr = 1e-6;
dt = 0.25;

a = dt*lambda/2;
[N1,N2] = size(u);
il = [1,1:N2-1];
ir = [2:N2,N2];
iu = [1,1:N1-1];
id = [2:N1,N1];

for k = 1:NumSteps
    ul = u(:,il);
    ur = u(:,ir);
    uu = u(iu,:);
    ud = u(id,:);
    c = a./sqrt(EpsSqr + (ur - u).^2 + (ud - u).^2);
    cl = c(:,il);
    cu = c(iu,:);
    u = (u + dt*f + c.*(ur + ud) + cl.*ul + cu.*uu) ...
        ./ (1 + dt + 2*c + cl + cu);
end


