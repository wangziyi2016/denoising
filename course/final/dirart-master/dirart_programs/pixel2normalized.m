function vecout=pixel2normalized(vec)
pos = get(gcbf,'Position');
vecout = vec;
vecout(1:2:end) = vecout(1:2:end)/pos(3);
vecout(2:2:end) = vecout(2:2:end)/pos(4);
return;
