function imgout = denoise_img(filter,imgin,varargin)
%
%	imgout = denoise_img(filter,imgin,[arg1,[arg2,[arg3]]])
%
imgout = imgin;

% Set up default parameters
switch filter
	case {1,2}
		arg1 = 2;
	case 3
		arg1 = 3;
		arg2 = 4;
		arg3 = 2;
	case 4
		arg1 = 3;
	case 5
		arg1 = 3;
		arg2 = 2;
		arg3 = 2;
	case 6
		arg1 = 5;
	case 9
		arg1 = 2;
	case 10
		arg1 = 3;
		arg2 = 10;
	case 11
		arg1 = 10;
	case 12
		arg1 = 2;
		arg2 = 10;
	case 13
		arg1 = 3;
		arg2 = 4;
		arg3 = 8;
end
if nargin > 2
	arg1 = varargin{1};
	if nargin > 3
		arg2 = varargin{2};
		if nargin > 4
			arg3 = varargin{3};
		end
	end
end

try
	img = double(imgin);
	maxval = max(img(:));
	img = img / maxval;

	switch filter
		case 1
			% Gaussian low pass filter
			out = lowpass2d(img, arg1);
		case 2
			out = bfilter2(img,arg1,[arg1 0.1]);
			% 		out = bfilter2(img,arg1);
		case 3
			% Artistic filter
			out = smoothing(img, [],arg1, arg2, arg3/2);
		case 4
			% Bilateral and Cross-Bilateral Filter using the Bilateral Grid
			out = bilateralFilter(img, img,0,1,arg1, 1,1);
		case 5
			% Nonlocal means filtering
			out = NLmeansfilter(img, arg1, arg2, arg3);
		case 6
			% Faster Kuwahara
			out = FasterKuwahara(img,5);
		case 7
			% Frost filter
			out = frost(img);
		case 8
			% Lee denoising filter
			out = lee(img);
		case 9
			% Symmetric nearest neighbor edge-preserving filter
			out = snn(img,arg1);
		case 10
			% Total variation image denoising
			out = tvdenoise(img,arg1,arg2);
		case 11
			% Denoising using Fourth Order PDE
			out = fpdepyou(img,arg1);
		case 12
			% Anisotropic Diffusion
			out = anisodiff2D(img,arg2,1/7,1/arg1,1);
		case 13
			% Nonlocal means denoising
			options.k = arg1;      % half size for the windows
			options.T = 0.1;		% width of the gaussian, relative to max(M(:))  (=1 here)
			% 		options.max_dist = 15;  % search width, the smaller the faster the algorithm will be
			options.max_dist = arg2;	% search width, the smaller the faster the algorithm will be
			% 		options.ndims = 30;     % arg2 of dimension used for distance computation (PCA dim.reduc. to speed up)
			options.ndims = arg3;     % arg2 of dimension used for distance computation (PCA dim.reduc. to speed up)
			options.do_patchwise = 0;
			out = perform_nl_means(img,options);
% 		case 14
% 			% Bayesian Least Squares - Gaussian Scale Mixture denoising
% 			options.arg1 = arg1;	% half size for the windows
% 			out = perform_blsgsm_denoising(img,options);
		otherwise
			return;
	end

	imgout = cast(out * maxval,class(imgin));
catch
	fprintf('Error: %s\n',lasterr);
end

