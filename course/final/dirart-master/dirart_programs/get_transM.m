function transM = get_transM(planC,scanno)
%
% transM = get_transM(planC,scanno)
%
if ~exist('planC','var') || isempty(planC)
	[filename1, pathname1] = uigetfile({'*.mat'}, 'Select CERR plan to image');	% Load a 3D image in MATLAB *.mat file
	if filename1 == 0
		setinfotext('Loading image is cancelled');
        transM = [];
		return;
	end

	filename1 = [pathname1,filename1];
	load(filename1);
end

if ~exist('scanno','var') || isempty(scanno)
    scanno = SelectScanFromPlanC(planC,'Select a scan to read transM');
    if scanno == 0
        transM = [];
        return;
    end
end

indexS = planC{end};
transM = planC{indexS.scan}(scanno).transM;



