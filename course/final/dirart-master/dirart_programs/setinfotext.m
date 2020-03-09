function setinfotext(msg)
% This is a supporting function used by the registration GUI.
%
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

obj = findobj(gcbf, 'Tag', 'infotext');
if ~isempty(obj)
	curtext = get(obj,'String');
	cr = sprintf('\n');
	if size(curtext,1) > 1
		%text2 = strtrim(curtext(1,:));
		text2 = '';
		for k=1:size(curtext,1)
			trimmedstr = strtrim(curtext(k,:));
			if strcmpi(trimmedstr,'ready') == 1 || strcmpi(trimmedstr,'busy') == 1 || isempty(trimmedstr)
				continue;
			end
			text2 = [text2 trimmedstr cr];
		end
		curtext = text2;
	end

	s = findstr(curtext,cr);
	if length(s) > 7
		curtext = curtext((s(end-7)+1):end);
	end
	
	if ~isempty(curtext) && curtext(end) ~= cr
		curtext = [curtext cr];
	end
	curtext = [curtext msg];
	set(obj,'String', curtext);
	drawnow;
end
return;
