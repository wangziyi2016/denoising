function hdr = get_micropet_img_hdr(filename)

if strcmp(filename(end-2:end),'hdr') ~= 1
	filename = [filename '.hdr'];
end

if ~exist(filename,'file')
	error(sprintf('File %s does not exist',filename));
end

hdr = struct([]);
hdr(1).dummy=1;

fid = fopen(filename,'r');
while 1
	tline = fgetl(fid);
	if ~ischar(tline)
		break
	end
	
	if tline(1) == '#'
		continue;
	end
	
	L = length(tline);
	
	if L > 8 && strcmp(tline(1:8),'ROI_file') == 1
		continue;
	elseif L > 8 && strcmp(tline(1:7),'singles') == 1
		continue;
	elseif strcmp(tline,'end_of_header') == 1
		break;
	end
	
	space_idx = strfind(tline,' ');
	name = tline(1:space_idx-1);
	value = tline(space_idx+1:end);
	
	hdr = setfield(hdr,name,value);
	%disp(sprintf('%s\t\t%s',name,value));
	%disp(tline)
end

rmfield(hdr,'dummy');

fclose(fid);


	