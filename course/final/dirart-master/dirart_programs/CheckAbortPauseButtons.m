function abortflag = CheckAbortPauseButtons(mainfigure,resetflag)
%
% This is a supporting function of the deformable registration GUI.
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2007, dyang@radonc.wustl.edu
%
if isempty(mainfigure)
	abortflag = 0;
	return;
end

if ~exist('resetflag','var')
	resetflag = 0;
end

% Check the 'Abort' and 'Pause' button status
handles = guidata(mainfigure);
%pauseflag = get(handles.gui_handles.pausebutton,'Value');
%abortflag = get(handles.gui_handles.abortbutton,'Value');
pauseflag = strcmp(get(handles.gui_handles.Pause_Registration_Menu_Item,'Checked'),'on');
abortflag = strcmp(get(handles.gui_handles.Abort_Registration_Menu_Item,'Checked'),'on');
stop_stage_flag = strcmp(get(handles.gui_handles.Stop_Current_Stage_Menu_Item,'Checked'),'on');
if stop_stage_flag == 1
	abortflag = 2;
end

if abortflag >= 1
	if resetflag == 1
		%set(handles.gui_handles.abortbutton,'Value',0);
		%set(handles.gui_handles.pausebutton,'Value',0);
		set(handles.gui_handles.Pause_Registration_Menu_Item,'Checked','off');
		set(handles.gui_handles.Abort_Registration_Menu_Item,'Checked','off','Enable','on','Label','Abort');
		set(handles.gui_handles.Stop_Current_Stage_Menu_Item,'Checked','off','Enable','on');
		set(handles.gui_handles.abortbutton,'string','Abort','enable','on');
		set(handles.gui_handles.pausebutton,'string','Pause','enable','on');
	end
	return;
end

if pauseflag == 1
	disp('Paused');
	figurename = get(mainfigure,'Name');
	set(mainfigure,'Name',[figurename ' - Paused']);
	set(handles.gui_handles.pausebutton,'string','Resume','enable','on');
end

while pauseflag == 1
	drawnow;
	pause(0.1);
	%pauseflag = get(handles.gui_handles.pausebutton,'Value');
	%abortflag = get(handles.gui_handles.abortbutton,'Value');
	pauseflag = strcmp(get(handles.gui_handles.Pause_Registration_Menu_Item,'Checked'),'on');
	abortflag = strcmp(get(handles.gui_handles.Abort_Registration_Menu_Item,'Checked'),'on');
	stop_stage_flag = strcmp(get(handles.gui_handles.Stop_Current_Stage_Menu_Item,'Checked'),'on');
	if stop_stage_flag == 1
		abortflag = 2;
	end

	if abortflag >= 1
		if resetflag == 1
			%set(handles.gui_handles.abortbutton,'Value',0);
			%set(handles.gui_handles.pausebutton,'Value',0);
			set(handles.gui_handles.Pause_Registration_Menu_Item,'Checked','off');
			set(handles.gui_handles.Abort_Registration_Menu_Item,'Checked','off','Enable','on','Label','Abort');
			set(handles.gui_handles.Stop_Current_Stage_Menu_Item,'Checked','off','Enable','on');
			set(handles.gui_handles.abortbutton,'string','Abort','enable','on');
			set(handles.gui_handles.pausebutton,'string','Pause','enable','on');
		end
		return;
	end
end

%set(handles.gui_handles.pausebutton,'Value',0);
set(handles.gui_handles.Pause_Registration_Menu_Item,'Checked','off');
set(handles.gui_handles.pausebutton,'string','Pause','enable','on');


