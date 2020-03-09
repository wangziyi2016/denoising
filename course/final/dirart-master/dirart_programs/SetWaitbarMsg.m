function SetWaitbarMsg(flag,H,val,msg)

if flag == 1
	waitbar(val,H,msg);
else
	disp(msg);
end

