function dvfno = which_DVF_to_process(handles,question,title)
%
%	dvfno = which_DVF_to_process(handles)
%
if isempty(handles.reg.dvf.x) && isempty(handles.reg.idvf.x)
	dvfno = 0;	% No DVF available
	return;
end

if ~exist('question','var')
	question = 'Which DVF to process?';
end

if ~exist('title','var')
	title = 'DVF Post-Processing';
end

if ~isempty(handles.reg.dvf.x) && ~isempty(handles.reg.idvf.x)
	answer = questdlg(question,title,'DVF','Inverse DVF','Cancel','DVF');
elseif ~isempty(handles.reg.dvf.x)
	answer = questdlg(question,title,'DVF','Cancel','DVF');
else
	answer = questdlg(question,title,'Inverse DVF','Cancel','inverse DVF');
end

switch lower(answer)
	case 'cancel'
		dvfno = 0;
	case 'inverse dvf'
		dvfno = 2;
	otherwise
		dvfno = 1;
end


