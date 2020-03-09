function [mask,phi]=image_boundary_mask(imin,delta_t,mu,v,lambda_in,lambda_out,dbgflag)
%
% Function: image_boundary_mask(imin)
%
% This function will find the image outer boundary and return a mask for
% the interesting part of the image
%
% Implementation by Deshan Yang, 05/2006
%

if( ~exist('dbgflag') )
	dbgflag = 0;
end

imins = image_smoothing(imin);	% Smooth the image
imins = imins/max(imins(:))*255;

[h,w] = size(imin);
x=[3 w-3 w-3 3 3];
y=[3 3 h-3 h-3 3];
initmask = poly2mask(x,y,h,w);
phi = direct_sdist(initmask,0,1);


eps=1;

% Step 1: input parameters
%
% dlgTitle='Activate Contour Based on Image Histogram';
% 
% mu = 100;
% v=0;
% lambda_in=1e-2;
% lambda_out=3e-1;
% sigma=10;
% eps = 1;
% delta_t=0.1;
% maxiter=200;
% 
% Levelset evolution

phi0_old = phi;
if( dbgflag )
	figure;imagesc(imin);daspect([1 1 1]);colormap('gray');
	hold on;
	contour(phi,[0 0 0],'r','LineWidth',2);
	drawnow;
end

maxiter = 200;
lambda=1e-2;

for iter=1:maxiter
	disp(sprintf('Iteration # %d',iter));

	phi = direct_sdist(phi,0,0);	% Re-initialize the levelset function
	
	if( iter ~= 1 & mean(mean((phi0_old-phi).^2)) < 1e-3 )
		break;
	end
	
	phi0_old = phi;
	
	%[Fgrad, kappa]=curve_derivatives_2(phi);
	kappa = curvature(phi,1,1);
	[delta_hv, dummy]=delta_h(phi,eps,2);
	H = (phi>0);
	cin = sum(sum(imins.*H))/sum(H(:));
	cout = sum(sum(imins.*(1-H))/sum(sum(1-H)));
	
	temp = lambda_in*(imins-cin).^2-lambda_out*(imins-cout).^2;

	%ka2 = sqrt(abs(kappa)).*sign(kappa);
	%phi = phi + delta_t *delta_hv .* (mu*ka2 - temp + v);
	phi = phi + delta_t *delta_hv .* (mu*kappa - temp + v);
	phi = lowpass2d(phi,1);
	%phi = phi + delta_t *delta_hv .* (sqrt(abs(kappa))*mu.*sign(kappa) - temp + v);
	%phi = phi + delta_t *delta_hv .* ((abs(kappa)*mu).^2.*sign(kappa) - temp + v);
		
	if( dbgflag )
		hold off;
		imagesc(imin);daspect([1 1 1]);colormap('gray');
		hold on;
		contour(phi,[0 0 0],'r','LineWidth',2);
		drawnow;
	end
end

mask = (phi >= 0) ;


