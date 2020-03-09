%% Anisotropic Diffusion Demonstration
%
%  Ashutosh Priyadarshy
%
%  Input Image: 'very+little+degeneration.jpg'
%

% Close any previous windows and clear the workspace. 
close all; clear all; 

% Read in the image. Scale it and noise it up. 
k = 400; 
iter_times=30;
j = imread('project.tiff'); 
j = double(j)/255; 
oj=j;
j = imnoise(j,'gaussian',0.,.03);
% Show the noisy image that will be processed with Anisotropic Diffusion.
imagesc(j); colormap gray;
title('image with noise');

%% Begin Anisotropic Diffusion Algorithm

% Set the number of updates of the AD Image. 
for iter = 1:iter_times

    %%% Compute Gradient Images
    % North Gradient 
    north = zeros(size(j,1), size(j,2)); 
    north(2:end, 1:end) =  j(1:end-1, 1:end) ;
    north(1, :) = j(1, :); 

    del_j_north = north - j;

    % South Gradient.
    south = zeros(size(j,1), size(j,2)); 
    south(1:end-1, 1:end) =  j(2:end, 1:end) ;
    south(end, :) = j(end, :); 

    del_j_south = south - j;

    % West Gradient.
    west = zeros(size(j,1), size(j,2)); 
    west(:, 2:end) =  j(:, 1:end-1) ;
    west(:, 1) = j(:, 1); 

    del_j_west = west - j;

    % East Gradient.
    east = zeros(size(j,1), size(j,2));
    east(:, 1:end-1) =  j(:, 2:end);
    east(:, end) = j(:, end); 

    del_j_east = east - j;

    %%% Compute 2rd Gradient Images

    
    
    % Calculate Diffusion Coefficients.
    cn = diff_co(del_j_north,k);
    cs = diff_co(del_j_south,k);
    ce = diff_co(del_j_east,k);
    cw = diff_co(del_j_west,k);

    % Update the image on this iteration. 
    j_plus_1 = j + 0.25.*(cn.*del_j_north + cs.*del_j_south + east.*del_j_east + west.*del_j_west);
    % Set j as updated one, make it clear what's happening
    j = j_plus_1; 

end
psnr=size(j,1)*size(j,2)/sum(sum((oj-j).^2));
% Display the results. 
figure(2); imagesc(j); colormap gray
title(['Image with Anisotropic Diffusion Applied ' num2str(iter) ' times.']);
