function offsets = User_Input_Offsets(name,current_offsets)
prompt={'Y','X','Z'};
numlines=1;
defaultanswer={num2str(current_offsets(1)),num2str(current_offsets(2)),num2str(current_offsets(3))};
options.Resize = 'on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
if ~isempty(answer)
	offsets(1) = str2num(answer{1});
	offsets(2) = str2num(answer{2});
	offsets(3) = str2num(answer{3});
else
	offsets = [];
end
