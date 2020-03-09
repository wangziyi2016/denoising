function airmask = segment_air(im,disksize)

m1 = (im >= 400);
se = strel('disk',disksize);
m2 = imopen(m1,se);
m3 = imfill(m2,[1,1,1]);
airmask = uint8(m3-m2);
