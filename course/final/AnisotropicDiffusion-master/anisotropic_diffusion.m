function [ j,psnr_list,snr_list ] = anisotropic_diffusion( image, dt,num_iter, k,II)

j = image; 
j = double(j)/255; 

for iter = 1:num_iter
    
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

    cn = exp(-(del_j_north./k).^2);
    cs = exp(-(del_j_south./k).^2);
    ce = exp(-(del_j_east./k).^2);
    cw = exp(-(del_j_west./k).^2);
    
    j_plus_1 = j + 0.25.*dt.*(cn.*del_j_north + cs.*del_j_south + east.*del_j_east + west.*del_j_west);
    j = j_plus_1; 
    [psnr_list(iter),snr_list(iter)]=psnr(uint8(255*j),II);
    
end
end

