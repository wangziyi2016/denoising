function view_structs_3D(voxeldim,varargin);
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

figure,
clf reset;
hold on;
axis off

colors = lines(64);
count = 1;

for n=1:(nargin-1)
    V = varargin{n};
	V = padImage(V, 1, 0);
	for m = 1:max(V(:))
		D = single(V==m);
		%D = getDownsample3(D, 2, 1);
		D = lowpass3d(D,1);

		S = size(D);

		[x,y,z,D] = subvolume(D,[1,S(1),1,S(2),1,S(3)]);

		%coloridx = round(size(colors,1)/(nargin+2))*(n+1);
		coloridx = count;
		count = count+1;

		fprintf('Rendering structure %d\n',n);
		%patch(isosurface(x,y,z,D, 0.1),'FaceColor',colors(coloridx,:),'EdgeColor','none','FaceAlpha',1);
		patch(isosurface(x,y,z,D, 0.5),'FaceColor',colors(coloridx,:),'EdgeColor','none','FaceAlpha',1);
		drawnow;
	end
end

h=gca;
view(3);
%axis([1 S(1) 1 S(2) 1 S(3)]);

colormap(hsv);
lighting gouraud;
%view(42.48,-15.40);

%daspect([voxeldim(1) voxeldim(2) voxeldim(3)]);
daspect(voxeldim);

light('Color','white','Position',[22, 0, -8],'Style','infinite');
light('Color','white','Position',[-535.04, 9.98, 700.51],'Style','local');

axis off;

hold off;
drawnow;


