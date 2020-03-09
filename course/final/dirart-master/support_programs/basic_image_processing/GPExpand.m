%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expand an image as per the Gaussian Pyramid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IResult = GPExpand(I)

Wt = [0.0500    0.2500    0.4000    0.2500    0.0500];

dim = size(I);
newdim = dim*2;
IResult = zeros(newdim,class(I)); % Initialize the array in the beginning ..
I=single(I);
m = [-2:2];n=m;

switch length(dim)
	case 1
		%% Pad the boundaries.
		I = [ I(1) ;  I ;  I(dim(1))];
		for i = 0 : newdim(1) - 1
			pixeli = (i - m)/2 + 2;  idxi = find(floor(pixeli)==pixeli);
			A = I(pixeli(idxi)) .* Wt(m(idxi)+3);
			IResult(i + 1)= 2 * sum(A(:));
		end
	case 2
		%% Pad the boundaries.
		I = [ I(1,:) ;  I ;  I(dim(1),:) ];  % Pad the top and bottom rows.
		I = [ I(:,1)    I    I(:,dim(2)) ];  % Pad the left and right columns.
		Wt2 = Wt'*Wt;

		for i = 0 : newdim(1) - 1
			for j = 0 : newdim(2) - 1
				pixeli = (i - m)/2 + 2;  idxi = find(floor(pixeli)==pixeli);
				pixelj = (j - m)/2 + 2;  idxj = find(floor(pixelj)==pixelj);
				A = I(pixeli(idxi),pixelj(idxj)) .* Wt2(m(idxi)+3,m(idxj)+3);
				IResult(i + 1, j + 1)= 4 * sum(A(:));
			end
		end
	case 3
		Wt3 = ones(5,5,5);
		for i = 1:5
			Wt3(i,:,:) = Wt3(i,:,:) * Wt(i);
			Wt3(:,i,:) = Wt3(:,i,:) * Wt(i);
			Wt3(:,:,i) = Wt3(:,:,i) * Wt(i);
		end
		
		%% Pad the boundaries
		I2 = zeros(dim+2,class(I));
		I2(2:1+dim(1),2:1+dim(2),2:1+dim(3)) = I;
		I2(1,:,:)=I2(2,:,:);I2(end,:,:)=I2(end-1,:,:);
		I2(:,1,:)=I2(:,2,:);I2(:,end,:)=I2(:,end-1,:);
		I2(:,:,1)=I2(:,:,2);I2(:,:,end)=I2(:,:,end-1);
		I=I2; clear I2;
		
		
		for j = 0 : newdim(2) - 1
			if( int16(j/2)*2 == j )
				pixeljs{j+1} = [j-2 j j+2]/2+2;
				ns{j+1} = [-2 0 2]+3;
			else
				pixeljs{j+1} = [(j-1) (j+1)]/2+2;
				ns{j+1} = [-1 1]+3;
			end
		end
		
		for k = 0 : newdim(3) - 1
			if( int16(k/2)*2 == k )
				pixelks{k+1} = [(k-2) k (k+2)]/2+2;
				ls{k+1} = [-2 0 2]+3;
			else
				pixelks{k+1} = [(k-1) (k+1)]/2+2;
				ls{k+1} = [-1 1]+3;
			end
		end
		
		for i = 0 : newdim(1) - 1
			if int16(i/2)*2 == i
				pixelis{i+1} = [i-2 i i+2]/2+2;
				ms{i+1} = [-2 0 2]+3;
			else
				pixelis{i+1} = [(i-1) (i+1)]/2+2;
				ms{i+1} = [-1 1]+3;
			end
		end		

		H = waitbar(0,'Progress');
		for i = 0 : newdim(1) - 1
			waitbar(i/newdim(1),H,sprintf('(%d%%) %d out of %d',round(i/newdim(1)*100),i,newdim(1)));
			
			for j = 0 : newdim(2) - 1
				for k = 0 : newdim(3) - 1
					A = I(pixelis{i+1},pixeljs{j+1},pixelks{k+1}) .* Wt3(ms{i+1},ns{j+1},ls{k+1});
					IResult(i + 1, j + 1,k+1)= 8 * sum(A(:));
				end
			end
		end
		close(H);
end

