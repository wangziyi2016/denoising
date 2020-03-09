function handles = CheckSettingParameters(handles)
%
%	handles = CheckSettingParameters(handles)
%
if ~isfield(handles.images(1),'UID')
	handles.images(1).UID = createUID('SCAN');
	handles.images(2).UID = createUID('SCAN');
end

N = handles.gui_options.num_panels;

if ~isfield(handles.reg.dvf,'info')
	handles.reg.dvf.info = [];
end

if ~isempty(handles.reg.dvf.x) && isempty(handles.reg.dvf.info)
	handles = FillDVFInfo(handles,1);
end

if ~isfield(handles.reg.idvf,'info')
	handles.reg.idvf.info = [];
end
if ~isempty(handles.reg.idvf.x) && isempty(handles.reg.idvf.info)
	handles = FillDVFInfo(handles,2);
end

if size(handles.gui_options.DVF_displays,2) == 1
	handles.gui_options.DVF_displays(:,1) = max(handles.gui_options.DVF_displays(:,1),1);
	handles.gui_options.DVF_displays(:,2) = 1;
end
handles.gui_options.DVF_displays(:,2) = max(handles.gui_options.DVF_displays(:,2),1);

if numel(handles.gui_options.slidervalues) == 3
	handles.gui_options.slidervalues = repmat(handles.gui_options.slidervalues,N,1);
end

if numel(handles.gui_options.checkerboard_size) == 3
	handles.gui_options.checkerboard_size = repmat(handles.gui_options.checkerboard_size,N,1);
end

if numel(handles.gui_options.motion_grid_size) == 3
	handles.gui_options.motion_grid_size = repmat(handles.gui_options.motion_grid_size,N,1);
end

handles.gui_options.DoseDisplayOptions.display_isodose_colorwash = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_colorwash);
handles.gui_options.DoseDisplayOptions.display_isodose_lines = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_lines);
handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor);
handles.gui_options.DoseDisplayOptions.transparency = MakeVector(N,handles.gui_options.DoseDisplayOptions.transparency);
handles.gui_options.DoseDisplayOptions.display_isodose_line_label = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_line_label);
handles.gui_options.DoseDisplayOptions.display_isodose_line_label_font_size = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_line_label_font_size);
handles.gui_options.DoseDisplayOptions.display_isodose_line_width = MakeVector(N,handles.gui_options.DoseDisplayOptions.display_isodose_line_width);
handles.gui_options.DoseDisplayOptions.dose_to_display = MakeVector(N,handles.gui_options.DoseDisplayOptions.dose_to_display);

handles.gui_options.Structure_Draw_Contour_Lines = MakeVector(N,handles.gui_options.Structure_Draw_Contour_Lines);
handles.gui_options.Structure_Fill_Color = MakeVector(N,handles.gui_options.Structure_Fill_Color);
handles.gui_options.Structure_Color_Fill_Alpha = MakeVector(N,handles.gui_options.Structure_Color_Fill_Alpha);
handles.gui_options.contour_line_thickness = MakeVector(N,handles.gui_options.contour_line_thickness);
handles.gui_options.DVF_colorwash_alpha = MakeVector(N,handles.gui_options.DVF_colorwash_alpha);
handles.gui_options.motion_vector_line_width = MakeVector(N,handles.gui_options.motion_vector_line_width);
handles.gui_options.display_geometry_limit_mode = MakeVector(N,handles.gui_options.display_geometry_limit_mode);

handles.gui_options.DoseDisplayOptions.dose_to_display = MakeVector(N,handles.gui_options.DoseDisplayOptions.dose_to_display);
handles.gui_options.DoseDisplayOptions.mode = MakeVector(N,handles.gui_options.DoseDisplayOptions.mode);
handles.gui_options.DoseDisplayOptions.base = MakeVector(N,handles.gui_options.DoseDisplayOptions.base);
handles.gui_options.DoseDisplayOptions.colorwash_min = MakeVector(N,handles.gui_options.DoseDisplayOptions.colorwash_min);
handles.gui_options.DoseDisplayOptions.colorwash_min = MakeVector(N,handles.gui_options.DoseDisplayOptions.colorwash_min);
handles.gui_options.DoseDisplayOptions.colorwash_max = MakeVector(N,handles.gui_options.DoseDisplayOptions.colorwash_max);

if ~iscell(handles.gui_options.DoseDisplayOptions.isodose_lines)
	handles.gui_options.DoseDisplayOptions = rmfield(handles.gui_options.DoseDisplayOptions,'isodose_lines');
	for k = 1:N
		handles.gui_options.DoseDisplayOptions.isodose_lines{k} = 110:-10:10;
	end
end

return;

function newval = MakeVector(len,val)
newval = val;
if length(val) == 1
	newval = ones(1,len)*val;
end


return;

