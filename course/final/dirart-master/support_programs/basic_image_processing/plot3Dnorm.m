function plot3Dnorm(V)

x1 = [0 V(1,1)];
x2 = [0 V(1,2)];
x3 = [0 V(1,3)];
y1 = [0 V(2,1)];
y2 = [0 V(2,2)];
y3 = [0 V(2,3)];
z1 = [0 V(3,1)];
z2 = [0 V(3,2)];
z3 = [0 V(3,3)];
plot3(x1,y1,z1);
hold on;
plot3(x2,y2,z2,':');
plot3(x3,y3,z3,'--');

