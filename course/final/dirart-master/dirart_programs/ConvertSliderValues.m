function [slidervalues1,slidervalues2,slidervaluesc] = ConvertSliderValues(handles,slidervalues,displaymode)
%
%	slidervalues1 - for image 1
%	slidervalues2 - for image 2
%	slidervaluesc - for combined image
%
[dim1,offs1] = GetImageDisplayDimensionAndOffsets(handles,1);
[dim2,offs2] = GetImageDisplayDimensionAndOffsets(handles,2);
[dimc,offsc] = GetImageDisplayDimensionAndOffsets(handles,3);

slidervalues1 = slidervalues;
slidervalues2 = slidervalues;

switch displaymode
	case {1,4}
		slidervalues1 = slidervalues;
		slidervalues2 = slidervalues + offs1 - offs2;
		slidervaluesc = slidervalues + offs1 - offs2 - offsc;
	case {2,5,10}
		slidervalues1 = slidervalues - offs1 + offs2;
		slidervalues2 = slidervalues;
		slidervaluesc = slidervalues - offsc;
	case {3,6,7,19,20,8,9,14,15,16,17}
		slidervalues1 = slidervalues - offs1 + offs2 + offsc;
		slidervalues2 = slidervalues + offsc;
		slidervaluesc = slidervalues;
end


