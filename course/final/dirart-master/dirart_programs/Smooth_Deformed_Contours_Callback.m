function Smooth_Deformed_Contours_Callback(handles)
%
%
%
if isfield(handles.reg,'deformed_structure_masks')
	prompt={'Enter disc size'}; name='Enter disc size'; numlines=1;
	defaultanswer={'1'}; options.Resize = 'on';
	answer=inputdlg(prompt,name,numlines,defaultanswer,options);
	disc = 1;
	if ~isempty(answer)
		disc = str2num(answer{1});
	end

	se = strel('arbitrary',ones(disc,disc,disc));

	N = floor(log2(max(single(handles.reg.deformed_structure_masks(:)))))+1;

	for k = 1:N
		maskbit = bitget(handles.reg.deformed_structure_masks,k);

		if k == 1
			masks_out=imclose(imopen(maskbit,se),se);
		else
			temp_masks_out = imclose(imopen(maskbit,se),se);
			masks_out = bitor(masks_out,bitshift(temp_masks_out,k-1));
		end
	end

	handles.reg.deformed_structure_masks = masks_out;
	handles = Logging(handles,'Smoothing the deformed structure contours, kernel size = %g',disc);

	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
	setinfotext('Deformed contours are smoothed.');
end
