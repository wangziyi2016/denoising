function ART_Contour_Deformation_Callback(handles)
%
%
%
% hObject    handle to ART_Contour_Deformation_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hf = openfig('contour_deformation.fig');
hf = contour_deformation_UI;
uiwait(hf);

if ishandle(hf)
	h = guidata(hf);
	close(hf);
	if direction == 1 && destination == 1
		h = rmfield(h,'planC2');	% we don't really need the second planC
	elseif direction == 2 && destination == 2
		h = rmfield(h,'planC1');	% we don't really need the first planC
	end
else
	return;
end

% if h.direction == 2 && (isfield(handles,'imvx') || isempty(handles.reg.idvf.x))
% 	% compute the inverse motion field
% 	handles = Compute_Reserse_Motion_Field_Menu_Item_Callback(hObject, eventdata, handles,1);
% end
% 
% deform the structures
h = deform_all_contours(handles, h);
if h.destination == 1
	planC = h.planC1;
else
	planC = h.planC2;
end

filename = SaveMAT2file('Saving planC with deformed structures',planC);
if filename ~= 0
	setinfotext('Contour deformation finished');
	clear h planC;
	handles = Logging(handles,'Contour deformation is finished.');	
	guidata(handles.gui_handles.figure1,handles);
end

