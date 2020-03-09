function Iout = remapKV2MV2(Iin)
%
% Convert image intensity of KVCT to MVCT
%

Iin2 = single(Iin)/1000;
idxes = Iin2>1;

Iout = 1.0133*Iin2;
Iout(idxes) = 0.0233*Iin2(idxes).^3 - 0.2864*Iin2(idxes).^2 + 1.2989*Iin2(idxes) - 0.0224;

Iout = cast(Iout*1000,class(Iin));
Iout = reshape(Iout,size(Iin));

