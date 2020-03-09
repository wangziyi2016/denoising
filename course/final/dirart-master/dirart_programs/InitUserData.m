function handles = InitUserData(handles)
%
%
%
handles = rmfield_from_struct(handles,'info');
% handles.info.name = 'Deformable Image Registration and Adaptive Radiatherapy Tool';
handles.info.name = 'DIRART Suite';
handles.info.program_fullpath = mfilename('fullpath');
[path1,name1] = fileparts(handles.info.program_fullpath);
handles.info.program_path = path1;
handles.info.program_name = name1;
handles.info.temp_storage_path = [path1 filesep 'temp_results'];
handles.info.log = cell(0);

handles = rmfield_from_struct(handles,'gui_options');
num_panels = 7;
handles.gui_options.num_panels = num_panels;
handles.gui_options.display_mode = [1 1;1 7;1 9;1 4;1 2;1 7;1 9];
handles.gui_options.display_enabled = ones(num_panels,1);
handles.gui_options.display_geometry_limit_mode = ones(num_panels,1);	% Display each image in its own dimension
handles.gui_options.checkerboard_size = repmat([50 50 50],[num_panels 1]);	% in mm
handles.gui_options.motion_grid_size = repmat([20 20 20],[num_panels 1]);	% in mm
handles.gui_options.motion_vector_line_width = ones(num_panels,1)*3;
handles.gui_options.window_center = ones(1,num_panels)*0.5;
handles.gui_options.window_width = ones(1,num_panels);
handles.gui_options.alphas = ones(1,num_panels);
handles.gui_options.contour_line_thickness = ones(1,num_panels)*2;
handles.gui_options.slidervalues = ones(num_panels,3);
handles.gui_options.colormap = 'Jet';
handles.gui_options.difference_image_range = 0;
handles.gui_options.current_axes_idx = 1;
handles.gui_options.button_down_axis_idx = 1;
handles.gui_options.DVF_displays = ones(num_panels,2);
handles.gui_options.DVF_colormap = 'jet';
handles.gui_options.DVF_colorwash_alpha = ones(num_panels,1)*0.5;
handles.gui_options.display_contour_in_own_view = ones(1,num_panels);
handles.gui_options.display_contour_1_in_all_views = zeros(1,num_panels);
handles.gui_options.display_contour_2_in_all_views = zeros(1,num_panels);
handles.gui_options.display_boundary_boxes = ones(1,num_panels);
handles.gui_options.display_NaN_boxes = ones(1,num_panels);
handles.gui_options.display_landmarks = ones(1,num_panels);
handles.gui_options.display_checkerboard_gridlines = zeros(1,num_panels);
handles.gui_options.display_image_in_color = zeros(1,num_panels);
handles.gui_options.display_checkerboard_in_color = zeros(1,num_panels);
handles.gui_options.display_colorbar = zeros(1,num_panels);
handles.gui_options.keep_aspect_ratio = ones(1,num_panels);

handles.gui_options.display_destination = 1;	% 1 to screen, 2 to file
handles.gui_options.display_maxprojection = 0;
handles.gui_options.draw_3D_ROI = 0;
handles.gui_options.ROI3D = [];
handles.gui_options.DoseDisplayOptions.mode = ones(1,num_panels)*2;	% Display absolute dose
handles.gui_options.DoseDisplayOptions.dose_to_display = zeros(1,num_panels);	% Display absolute dose

for k = 1:num_panels
	handles.gui_options.DoseDisplayOptions.isodose_lines{k} = 110:-10:10;
end

handles.gui_options.DoseDisplayOptions.isodose_line_colormap = 'lines';
handles.gui_options.DoseDisplayOptions.colorwash_colormap = 'jet';
handles.gui_options.DoseDisplayOptions.base = ones(1,num_panels)*6000;
handles.gui_options.DoseDisplayOptions.colorwash_max = ones(1,num_panels)*100;
handles.gui_options.DoseDisplayOptions.colorwash_min = ones(1,num_panels)*0;
handles.gui_options.DoseDisplayOptions.display_isodose_line_label = ones(1,num_panels);
handles.gui_options.DoseDisplayOptions.display_isodose_lines = ones(1,num_panels);
handles.gui_options.DoseDisplayOptions.display_isodose_lines_fillcolor = zeros(1,num_panels);
handles.gui_options.DoseDisplayOptions.display_isodose_colorwash = ones(1,num_panels);
handles.gui_options.DoseDisplayOptions.display_isodose_line_label_font_size = ones(1,num_panels)*15;
handles.gui_options.DoseDisplayOptions.display_isodose_line_width = ones(1,num_panels)*2;
handles.gui_options.DoseDisplayOptions.transparency = ones(1,num_panels)*0.5;
handles.gui_options.Structure_Color_Fill_Alpha = ones(1,num_panels)*0.5;
handles.gui_options.Structure_Draw_Contour_Lines = ones(1,num_panels);
handles.gui_options.Structure_Fill_Color = zeros(1,num_panels);

handles.gui_options.lock_between_display = 1;

handles = rmfield_from_struct(handles,'reg');
handles.reg.Multigrid_Stages = 4;
handles.reg.maxiters = [10 20 30 40 50];
handles.reg.max_motion_per_iteration = 0.5;
handles.reg.minimal_max_motion_per_pass = 1e-2;
handles.reg.minimal_max_motion_per_iteration = 2e-3;
handles.reg.Save_Temp_Results = 0;
handles.reg.Log_Output = 0;
handles.reg.Generate_Reverse_Consistent_Motion_Field = 0;
handles.reg.Force_Inverse_Consistency = 0;
handles.reg.passes_in_stages = [2 3 4 5 6];
handles.reg.last_registration_method = '';
handles.reg.registration_method = 1;
handles.reg.registration_framework = 'asymmetric';
handles.reg.smoothing_in_iteration = 3;
handles.reg.smoothing_after_pass = [0.5 0 0];
handles.reg.multigrid_filter_type = 1;	% Using the Gaussian filter as default
handles.reg.Intensity_Modulation = 0;
handles.reg.Use_Both_Image_Gradients = 0;
handles.reg.idvf.y = []; handles.reg.idvf.x = []; handles.reg.idvf.z = [];handles.reg.idvf.info = [];
handles.reg.dvf.y = []; handles.reg.dvf.x = []; handles.reg.dvf.z = [];handles.reg.dvf.info = [];

handles.reg.images_setting.image_coordinate_offsets = [0 0 0];	% not used anymore
handles.reg.images_setting.image_offsets = [0 0 0];
handles.reg.images_setting.image_current_offsets = [0 0 0];
handles.reg.images_setting.cropped_image_offsets_in_original = [0 0 0; 0 0 0];
handles.reg.images_setting.max_intensity_value = 1000;
handles.reg.images_setting.images_alignment_points = [1 1 1;1 1 1];

handles = rmfield_from_struct(handles,'ART');
handles.ART.dose = [];
handles.ART.dose_idx = 1;
handles.ART.structures = [];
handles.ART.structure_colors = [];
handles.ART.structure_display = [];
handles.ART.structure_names = cell(0);
handles.ART.structure_assocScanIDs = [];
handles.ART.structure_scanInfos = [];
handles.ART.structure_structInfos = [];
handles.ART.structure_assocImgIdxes = [];

handles = rmfield_from_struct(handles,'images');
handles.images(1) = CreateEmptyImage;
handles.images(2) = handles.images(1);

