function meshDir = LoadLibMeshContour
currDir = cd;
switch computer
	case 'PCWIN64'
		meshDir = fileparts(which('libMeshContour_win64.dll'));
		if ~libisloaded('libMeshContour_win64')
			cd(meshDir)
			try
				loadlibrary('libMeshContour_win64','MeshContour.h')
			catch ME
				%print_lasterror(ME);
				meshDir = '';
			end
			cd(currDir);
		end
	otherwise
		meshDir = fileparts(which('libMeshContour.dll'));
		if ~libisloaded('libMeshContour')
			cd(meshDir)
			try
				loadlibrary('libMeshContour','MeshContour.h')
			catch ME
				%print_lasterror(ME);
				meshDir = '';
			end
			cd(currDir);
		end
end
