function img = CreateEmptyImage()
%
%
%
img.image = [];
img.voxelsize = [1 1 1];			% The commond voxels after both images are loaded and resampled
img.origin = [0 0 0];				% Physical coordinate of the center of the first voxel (y=1,x=1,z=1), in mm
img.voxel_spacing_dir = [1 1 1];	% 1 means increasing, -1 means decreasing
img.original_voxelsize = [1 1 1]; 
img.structure_mask = [];
img.structure_name= [];
img.image_deformed = [];
img.filename = 'unknown';
img.type = 'unknown';
img.class = 'single';
img.UID = '';
img.DICOM_Info = [];
img.original_CERR_Scan_Struct = [];
img.LoadFrom = '';

