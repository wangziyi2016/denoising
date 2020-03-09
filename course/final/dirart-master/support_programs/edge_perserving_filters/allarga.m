function y = allarga(img, N)

[nr,nc, NN] = size(img);

img = [repmat(img(1,:,:), N, 1); img; repmat(img(nr,:,:), N, 1)];
  y = [repmat(img(:,1,:), 1, N), img, repmat(img(:,nc, :), 1, N)];

