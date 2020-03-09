function [ snr1 ] = my_snr( f,g )
   f=double(f);
   g=double(g);
   snr1=10*log10(sum(sum(f.^2))/sum(sum((f-g).^2)));
end

