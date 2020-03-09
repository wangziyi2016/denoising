function [img,h,w] = load_ima(filename)

if( ~exist('filename') )
	[filename, pathname] = uigetfile('*.ima', 'Load IMA image');

	if( filename == 0 )
		return;
	end
else
	pathname = [];
end

dlgTitle='Image Parameters';
prompt={'Enter width:';...
	'Enter height:';...
	'Enter offset:'};
def={num2str(640),num2str(640),num2str(6144)};
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);

if( length(answer) == 0 )
	return;
end

imwidth=str2num(answer{1});
imheight=str2num(answer{2});
imoffset=str2num(answer{3});
[header,img]=readima([pathname,filename],imwidth, imheight,imoffset);
img = cropImage(img);
img=min_maxnorm(img, [0,255]);
[h,w]=size(img);
return



function y=min_maxnorm(x,yrange)
% normalize the dynamic range bewteen two values 
% Written by: Issam El Naqa    date: 09/12/03
% x: input image
% y: normalized image
x=double(x);
xmin=min(x(:)); xmax=max(x(:));
ymin=yrange(1); ymax=yrange(2);
y=(x-xmin)./(xmax-xmin).*(ymax-ymin)+yrange(1);
return


function x = cropImage(x)
minCol = 1; minRow = 1;
[maxCol, maxRow] = size(x);
rows = find(~max(x'));
cols = find(~max(x));
for i=1:length(rows)
	if rows(i) ~= i
		minRow = rows(i-1)+1;
		maxRow = rows(i)-1;
		break;
	end
end
for i=1:length(cols)
	if cols(i) ~= i
		minCol = cols(i-1)+1;
		maxCol = cols(i)-1;
		break;
	end
end
x = imcrop(x,[minCol, minRow,  maxCol-minCol, maxRow-minRow]);

return

