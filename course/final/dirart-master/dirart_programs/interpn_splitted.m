function out = interpn_splitted(in,y,x,z,method,defval)

dim = size(in);
out = zeros(dim,'single');

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
			disp(sprintf('interpn_splitted: %d,%d,%d',ntr,nco,nsa));
			tr0 = (ntr-1)*dtr+1;
			tr1 = min(ntr*dtr,dim(1));
			co0 = (nco-1)*dco+1;
			co1 = min(nco*dco,dim(2));
			sa0 = (nsa-1)*dsa+1;
			sa1 = min(nsa*dsa,dim(3));
			
			tr = [tr0:tr1];
			co = [co0:co1];
			sa = [sa0:sa1];
			
			out(tr,co,sa) = interpn(in,y(tr,co,sa),x(tr,co,sa),z(tr,co,sa),method,defval);
		end
	end
end
