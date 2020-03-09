function transM = makeTransM(angleX,angleY,angleZ,shiftX,shiftY,shiftZ)
%
% transM = makeTransM(angleX,angleY,angleZ,shiftX,shiftY,shiftZ)
%

angleX = angleX/180*pi;
angleY = angleY/180*pi;
angleZ = angleZ/180*pi;

Rx = [1 0 0;0 cos(angleX) -sin(angleX);0 sin(angleX) cos(angleX)];
Ry = [cos(angleY) 0 sin(angleY);0 1 0; 0 -sin(angleY) cos(angleY)];
Rz = [cos(angleZ) -sin(angleZ) 0;sin(angleZ) cos(angleZ) 0; 0 0 1];

R = Rx*Ry*Rz;

transM = [R [shiftX;shiftY;shiftZ]; 0 0 0 1];
	