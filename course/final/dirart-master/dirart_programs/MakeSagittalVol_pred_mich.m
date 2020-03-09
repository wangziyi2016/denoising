
clear all
letter='x';
[volfilename1, patientdir] = uigetfile('','Select the file that has the predicted volume');
cd(patientdir)
load(volfilename1)
vdata_pred = optflow_pred95;  %%%% Make sure the data file has the name of vdata_pred
load Magee_V1andV95forSagPlotting.mat % Original V1 and V95 of Magee from collectem12_sagfn.m
load filenameinfo
ysc=pixelspacing*[0:size(vdata_pred,1)-1];
xsc_pred=slicespacing*[0:size(vdata_pred,3)-1];
xsc=slicespacing*[0:size(Voln_data_sag,3)-1];
cd ..
vol_ind = [1 2];


%color limits of figures
lower0=250;
upper0=1050;
lower200=250;
upper200=1050;
lower400=250;
upper400=1050;
lower600=250;
upper600=1050;
colaxis1=[lower0 upper0];
colaxis2=[lower200 upper200];
colaxis3=[lower400 upper400];
colaxis4=[lower600 upper600];

%Starting slices
slice1 = 75;
slice2 = 76;

%I don't remember the point of this, but it might be necessary
if(length(vol_ind) == 2)
    plot2(xsc, ysc, Voln_data_sag, slice1, colaxis1, letter, pixelspacing)
    plot1_pred(xsc_pred, ysc, vdata_pred, slice2, colaxis2, letter, pixelspacing)
elseif(length(vol_ind)==1)
    plot1_pred(xsc_pred, ysc, vdata_pred, slice1, colaxis1, letter, pixelspacing)
else
    error('Too many Indices')
end



%Make the figure and menu
iamnotfinished = 1;
while(iamnotfinished)
    if(length(vol_ind) == 2)
        nextans = menu('what do you want to do',{'increase slice1', 'decrease slice1', 'pick slice1', 'change color limit for 1',...
                'cancel','increase slice2', 'decrease slice2', 'pick slice2', 'change color limit for 2'});
    else
        nextans = menu('what do you want to do',{'increase a slice', 'decrease a slice', 'pick a slice', 'change color limit', 'cancel'});
    end
    if nextans == 1
        slice1 = slice1 +1;
        plot2(xsc, ysc, Voln_data_sag, slice1, colaxis1, letter, pixelspacing)
        
    elseif nextans ==2
        slice1 = slice1 -1;
        plot2(xsc, ysc, Voln_data_sag, slice1, colaxis1, letter, pixelspacing)
        
    elseif nextans == 3
        prompt=('which slice ?');
        slicetemp=inputdlg(prompt);
        slice1=str2num(slicetemp{1,1});
        plot2(xsc, ysc, Voln_data_sag, slice1, colaxis1, letter, pixelspacing)
    elseif nextans == 4
        anscolor= menu('select what to do',{['lower color limit currently at ',num2str(colaxis1(1))],...
                ['upper color limit currently at ',num2str(colaxis1(2))]});
        prompt = ('new limit: (2 Numbers with a space in between)');
        newLim = inputdlg(prompt);
        colaxis1 = str2num(newLim{1,1});
        plot2(xsc, ysc, Voln_data_sag, slice1, colaxis1, letter, pixelspacing)
    elseif nextans== 5
        iamnotfinished = 0;
    elseif nextans == 6
        slice2 = slice2 +1;
        plot1_pred(xsc_pred, ysc, vdata_pred, slice2, colaxis2, letter, pixelspacing)
        
    elseif nextans ==7
        slice2 = slice2 -1;
        plot1_pred(xsc_pred, ysc, vdata_pred, slice2, colaxis2, letter, pixelspacing)
        
    elseif nextans == 8
        prompt=('which slice ?');
        slicetemp=inputdlg(prompt);
        slice2=str2num(slicetemp{1,1});
        plot1_pred(xsc_pred, ysc, vdata_pred, slice2, colaxis2, letter, pixelspacing)
    elseif nextans == 9
        anscolor= menu('select what to do',{['lower color limit currently at ',num2str(colaxis1(1))],...
                ['upper color limit currently at ',num2str(colaxis1(2))]});
        prompt = ('new limit: (2 Numbers with a space in between)');
        newLim = inputdlg(prompt);
        colaxis2 = str2num(newLim{1,1});
        plot1_pred(xsc_pred, ysc, vdata_pred, slice2, colaxis2, letter, pixelspacing)
        
    end   
end


