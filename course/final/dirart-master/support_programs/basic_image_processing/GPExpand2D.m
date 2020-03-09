%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reduce an image applying Gaussian Pyramid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IResult = GPExpand2D(I,displayflag)

if ~exist('displayflag')
	displayflag = 1;
end

dim = size(I);
if length(dim) == 2
	IResult = GPExpand(I);
	return;
end

if displayflag == 1
	H = waitbar(0,'Progress');
	set(H,'Name','GPExpand2D ...');
end

for k=1:dim(3)
	if displayflag == 1
		waitbar((k-1)/dim(3),H,sprintf('(%d%%) %d out of %d',round((k-1)/dim(3)*100),k-1,dim(3)));
    else
        disp(sprintf('GPExpand2D (%d%%) %d out of %d',round((k-1)/dim(3)*100),k-1,dim(3)));
	end
	IResult(:,:,k) = GPExpand(squeeze(I(:,:,k)));
end

if displayflag == 1
	close(H);
end

