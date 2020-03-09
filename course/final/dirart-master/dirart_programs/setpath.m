function setpath()

P=path;

p = mfilename('fullpath');
p = [p '.m'];
[pathstr] = fileparts(p);
[pathstr2]=fileparts(pathstr);

if( isempty(strfind(P,'basic image functions')) )
	addpath([pathstr2 filesep 'basic image functions']);
end

if( isempty(strfind(P,'levelset base functions')) )
	addpath([pathstr2 filesep 'levelset base functions']);
end

if( isempty(strfind(P,'matlab extensions')) )
	addpath([pathstr2 filesep 'matlab extensions']);
end

if( isempty(strfind(P,'MATLAB levelset toolbox')) )
	addpath([pathstr2 filesep 'MATLAB levelset toolbox']);
end

if( isempty(strfind(P,pathstr)) )
addpath(pathstr);
end

clear P;


