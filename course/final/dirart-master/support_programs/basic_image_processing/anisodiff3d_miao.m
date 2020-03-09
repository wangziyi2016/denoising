function diff = anisodiff3d_miao(x, cerror, niter,type)
% Anisotropic diffusion routine based on Perona & Malik, PAMI, '90 
%         x     : - input image
%         niter :  # of iterations 
%         cerror: the uncertainty matrix
%         type -   diffusion function  'exp' gaussian, 'poly' rational polynomials
%         written by: Issam El Naqa         date: 04/20/04
%
[m,n,k] = size(x);
diff = x;
% Selected parameters from Miao, PMB 2003, might need tweaking?
kappa=1.75*cerror;  
lambda=0.15;
alpha=2;
for i = 1:niter
    %fprintf('\rIteration %d',i);
    % padding by zeros
    diffl = zeros(m+2, n+2, k+2);
    diffl(2:m+1, 2:n+1, 2:k+1) = diff;
    % North, South, East, West, Top, and Bottom gradients
    deltaN = diffl(1:m,2:n+1,2:k+1) - diff;
    deltaS = diffl(3:m+2,2:n+1,2:k+1) - diff;
    deltaE = diffl(2:m+1,3:n+2,2:k+1) - diff;
    deltaW = diffl(2:m+1,1:n,2:k+1) - diff;
    deltaT = diffl(2:m+1,2:n+1,1:k) - diff;
    deltaB = diffl(2:m+1,2:n+1,3:k+2) - diff;
    
    % diffusion function
    
    switch type 
        case 'exp'
            %disp('Exponential diffusion function.')
            cN = exp(-(deltaN./kappa).^2);
            cS = exp(-(deltaS./kappa).^2);
            cE = exp(-(deltaE./kappa).^2);
            cW = exp(-(deltaW./kappa).^2);
            cT = exp(-(deltaT./kappa).^2);
            cB = exp(-(deltaB./kappa).^2);
        case  'poly1'
            %disp('Rational polynomial diffusion function.')
            cN = 1./(1+exp(-(deltaN./kappa).^2));
            cS = 1./(1+exp(-(deltaS./kappa).^2));
            cE = 1./(1+exp(-(deltaE./kappa).^2));
            cW = 1./(1+exp(-(deltaW./kappa).^2));
            cT = 1./(1+exp(-(deltaT./kappa).^2));
            cB = 1./(1+exp(-(deltaB./kappa).^2));
        case  'poly2'
            %disp('Rational polynomial diffusion function.')
            cN = 1./(1+(deltaN./kappa).^2);
            cS = 1./(1+(deltaS./kappa).^2);
            cE = 1./(1+(deltaE./kappa).^2);
            cW = 1./(1+(deltaW./kappa).^2);
            cT = 1./(1+(deltaT./kappa).^2);
            cB = 1./(1+(deltaB./kappa).^2);
            
        case 'Tukey'
            testN=abs(deltaN)<=(alpha*kappa);
            gN=(deltaN./kappa);
            cN = (0.5*(1-gN.^2).^2).*double(testN);          
            testS=abs(deltaS)<=(alpha*kappa);
            gS=(deltaS./kappa);
            cS = (0.5*(1-gS.^2).^2).*double(testS);
            testE=abs(deltaE)<=(alpha*kappa);
            gE=(deltaE./kappa);
            cE = (0.5*(1-gE.^2).^2).*double(testE);
            testW=abs(deltaW)<=(alpha*kappa);
            gW=(deltaW./kappa);
            cW = (0.5*(1-gW.^2).^2).*double(testW);
            testT=abs(deltaT)<=(alpha*kappa);
            gT=(deltaT./kappa);
            cT = (0.5*(1-gT.^2).^2).*double(testT);
            testB=abs(deltaB)<=(alpha*kappa);
            gB=(deltaB./kappa);
            cB = (0.5*(1-gB.^2).^2).*double(testB);
        otherwise
            disp('Unknown diffusion function.')
    end
    
    diff = diff + lambda*(cN.*deltaN + cS.*deltaS + cE.*deltaE + cW.*deltaW+cT.*deltaT +cB.*deltaB);
    %gtitle=strcat('Diffusion at iteration=',num2str(i));
    %figure(i)
    %dispimage(diff,gtitle,1,1,1);
end


return