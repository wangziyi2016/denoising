function res = dice(mask1,mask2)

maskj = mask1&mask2;

res = 2 * sum(maskj(:)) / (sum(mask1(:))+sum(mask2(:)));

