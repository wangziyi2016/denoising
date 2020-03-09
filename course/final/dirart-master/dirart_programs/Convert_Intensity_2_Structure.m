function newStruct = Convert_Intensity_2_Structure(Img,val,RefImg)
%
%	newStruct = Convert_Intensity_2_Structure(Img,val,RefImg)
%
if ~exist('RefImg','var')
	RefImg = Img;
end

dim = size(Img);

for k = 1:dim(3)
	img2d = Img.image(:,:,k);
	[ys,xs,zs] = get_Image_XYZ_vectors(Img);
	contours = contourd(xs,ys,double(img2d),[val val]);
	
	for c = 1:length(contours)
		points = contours{c};
		segments(c).points = points;
	end
	
	
end


newStruct=initializeCERR('structures');
newStruct.contour = [];
