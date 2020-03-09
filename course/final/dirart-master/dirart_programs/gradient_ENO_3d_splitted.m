function [u,v,w,grad] = gradient_ENO_3d_splitted(im,method)

dim = size(im);

u = zeros(dim,'single');
v = u;
w = u;
grad = v;

if( prod(dim) > 256*256*100 )
	nstr = 4;
	nsco = 4;
	nssa = 4;
else
	nstr = 2;
	nsco = 2;
	nssa = 2;
end

dtr = ceil(dim(1)/nstr);dco = ceil(dim(2)/nsco);dsa=ceil(dim(3)/nssa);	% size of each section

for ntr = 1:nstr
	for nco = 1:nsco
		for nsa = 1:nssa
			disp(sprintf('gradient_ENO_3d_splitted: %d,%d,%d',ntr,nco,nsa));
			tr0 = (ntr-1)*dtr+1;
			tr1 = min(ntr*dtr,dim(1));
			co0 = (nco-1)*dco+1;
			co1 = min(nco*dco,dim(2));
			sa0 = (nsa-1)*dsa+1;
			sa1 = min(nsa*dsa,dim(3));
			
			tr0b = max(tr0-3,1);
			tr1b = min(tr1+3,dim(1));
			co0b = max(co0-3,1);
			co1b = min(co1+3,dim(2));
			sa0b = max(sa0-3,1);
			sa1b = min(sa1+3,dim(3));
			
			tr = tr0b:tr1b;
			co = co0b:co1b;
			sa = sa0b:sa1b;

			[u2,v2,w2,grad2] = gradient_ENO_3d(im(tr,co,sa),method);
			
			tr0c = [tr0 - tr0b + 1 : tr1 - tr0b + 1];
			co0c = [co0 - co0b + 1 : co1 - co0b + 1];
			sa0c = [sa0 - sa0b + 1 : sa1 - sa0b + 1];
			
			u(tr0:tr1,co0:co1,sa0:sa1) = u2(tr0c,co0c,sa0c);
			v(tr0:tr1,co0:co1,sa0:sa1) = v2(tr0c,co0c,sa0c);
			w(tr0:tr1,co0:co1,sa0:sa1) = w2(tr0c,co0c,sa0c);
			grad(tr0:tr1,co0:co1,sa0:sa1) = grad2(tr0c,co0c,sa0c);
		end
	end
end

