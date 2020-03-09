function denoise_files(filter,infolder,outfolder,filespec)
%
%	denoise_files(filter,infolder,outfolder,filespec)
%

d = dir([infolder filesep filespec]);
for k=1:length(d)
	name = d(k).name;
	if isdir(name)
		continue;
	else
		fprintf('File %d (%d): %s: ',k, length(d),name);
		infilename = [infolder filesep name];
		outfilename = [outfolder filesep name];
		if ~exist(outfolder,'dir')
			mkdir(outfolder);
		end
		res = denoise_1_file(filter,infilename,outfilename);
		if res == 1
			fprintf('Passed\n');
		else
			fprintf('Failed\n');
		end			
	end
end

disp('Denoise all finished.');

