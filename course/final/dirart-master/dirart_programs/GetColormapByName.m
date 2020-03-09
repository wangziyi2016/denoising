function mapdata = GetColormapByName(colormapname,levels)
%
%	mapdata = GetColormapByName(colormapname)
%
try
	str = ['mapdata=' colormapname '(' num2str(levels) ');'];
	eval(str);
catch
	mapdata = jet(levels);
end
