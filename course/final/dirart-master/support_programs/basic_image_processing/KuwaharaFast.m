function d = KuwaharaFast(image_in, L)
% Kuwahara filter implementation. Smoothing and edge preserving filter
%
%INPUTS:
% image_in->    input data - square array. Must be double or integer precision 
% L ->          kernel creation integer =1,2,3,4,5... 
%               kernel_size -> k = 4*L +1
%               kuwahara subwindow (regions 1-4) size R = 3,5,7,9....
%               Window size J=K= 2R-1;                J = 5,9,13,17......
%
%OUTPUTS:
% d->           double precision output array the same size as image_in. If image_in 
%               is an integer array, it will be converted to the double precision
%
% The Kuwahara filter work as follows:
% The sliding window size [K,K]is divided into 4 overlapping sub-windows size [R,R] such that 
% central pixel in [K,K] is included in every sub-window {R,R] (pixel abcd). 
%
%    ( a  a  ab   b  b)
%    ( a  a  ab   b  b)
%    (ac ac abcd bd bd)
%    ( c  c  cd   d  d)
%    ( c  c  cd   d  d)
%
% In each sub-window, the mean and variance are computed. The output value at the position of   
% central pixel set to the mean of the subwindow with the smallest variance. 
% Then window [K,K] moved to the next pixel.
%
% References:
% http://www.ph.tn.tudelft.nl/DIPlib/docs/FIP.pdf van Vliet "Fundamentals of Image
% Processing"  
% http://www.incx.nec.co.jp/imap-vision/library/wouter/kuwahara.html
%
% Other m-files required: ARRAY_PADD that can be downloaded from FEX:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=7720&objectType=FILE

% Subfunctions: none
% MAT-files required: none

%---------------------------------------------------|
% 	Sergei Koptenko, Resonant Medical, Montreal, Qc.|
% ph: 514.985.2442 ext265, www.resonantmedical.com  |
%      sergei.koptenko@resonantmedical.com          |
%---------------Aug/12/2006-------------------------|

if isinteger(image_in), image_in = double(image_in); end

if nargin <2, L =1; end  % Rank of the Kuwahara kernel
R = 2*L+1;      % size of the 1/4 sub-window in Kuwahara kernel
[d, indd] = array_padd(image_in, [L,L], 0, 'both', 'replicate');
MeanArray =  colfilt(d,[R,R],'sliding',@mean);
VarArray =  colfilt(d,[R,R],'sliding',@var);

LL1= (indd(3):1:indd(4))-L;
LL2= (indd(3):1:indd(4))+L;
ccol = size(image_in,2);
vccol = 1:1:ccol;

d = zeros(size(d,1),ccol);

for ii = indd(1): 1:indd(2),        % Going through rows
        curr_mean = [MeanArray(ii-L, LL1);  MeanArray(ii-L, LL2);  MeanArray(ii+L, LL2);  MeanArray(ii+L, LL1)];
        curr_std = [VarArray(ii-L, LL1);  VarArray(ii-L, LL2);  VarArray(ii+L, LL2);  VarArray(ii+L, LL1);];
        [tmp, iind] = min(curr_std);
        IND = sub2ind([4,ccol], iind, vccol);
        d(ii,:) = curr_mean(IND);
end
d = d(indd(1): 1:indd(2), :); % recover the original size
