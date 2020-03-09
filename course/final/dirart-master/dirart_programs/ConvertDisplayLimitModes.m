function newLimitMode = ConvertDisplayLimitModes(displaymode,limitmode)
newLimitMode = limitmode;
if limitmode == 1
	switch displaymode
		case {3,6,7,19,20}
			newLimitMode = 4;
		case {8,9}
			newLimitMode = 5;
		case {2,5,10,14,15,16,17}
			newLimitMode = 2;
		otherwise
			newLimitMode = 3;
	end
end

