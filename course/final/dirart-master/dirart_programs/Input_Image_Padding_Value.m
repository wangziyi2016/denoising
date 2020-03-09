function padval = Input_Image_Padding_Value()
%
%	val = Input_Image_Padding_Value()
%
padval = [];

prompt={'Value:  (0, nan)'};
name=sprintf('Please enter the padding value');
numlines=1;
defaultanswer={'nan'};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

if isempty(answer)
	return;
elseif strcmpi(answer,'nan')
	padval = nan;
else
	padval = str2double(answer{1});
end


