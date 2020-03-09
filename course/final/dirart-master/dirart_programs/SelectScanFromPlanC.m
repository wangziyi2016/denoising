function scanno = SelectScanFromPlanC(planC,namestr)
%
%	sel = SelectScanFromPlanC(planC)
%
indexS = planC{end};
N = length(planC{indexS.scan});
scanstrs = cell(1,N);

if ~exist('namestr','var')
	namestr = 'Select a scan';
end

if N > 1
	for k = 1:N
		scanstrs{k} = sprintf('%d - %s',k,planC{indexS.scan}(k).scanType);
	end
	[scanno,ok]=listdlg('ListString',scanstrs,'SelectionMode','single','Name',namestr,...
		'PromptString','There are multiple scans in the CERR plan, please select one scan',...
		'ListSize',[160 100]);
	if ok == 0
		scanno = 0;
		return;
    else
        fprintf('Select scan = %s\n',scanstrs{scanno});
	end
else
	scanno = 1;
end
