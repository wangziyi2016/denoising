function Iout = remapKV2MV(Iin)
%
% Convert image intensity of KVCT to MVCT
%

Iin2 = single(Iin)/1000;
idxes = Iin2>1;

Iout = Iin2;
%Iout = 0.1023*Iin2.^3 - 0.57*Iin2.^2 + 1.4664*Iin2;
Iout(idxes) = 0.1023*Iin2(idxes).^3 - 0.57*Iin2(idxes).^2 + 1.4664*Iin2(idxes);
%Iout(idxes) = 0.1334*Iin2(idxes).^3 - 0.6789*Iin2(idxes).^2 + 1.6008*Iin2(idxes)-0.0483;

Iout = cast(Iout*1000,class(Iin));
Iout = reshape(Iout,size(Iin));

