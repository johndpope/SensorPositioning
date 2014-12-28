function [ qs ] = Qeval( x, y, x1, y1, x2, y2, dmax )
%QEVAL Summary of this function goes here
%   Detailed explanation goes here

 qs = sqrt((((x-x1)^2+(x-x2)^2-(x1-x2)^2+(y-y1)^2+(y-y2)^2-(y1-y2)^2)^2*...
     (-1.0/4.0))/(((x-x1)^2+(y-y1)^2)*((x-x2)^2+(y-y2)^2))+1.0)/((((x-x1)^2+(y-y1)^2)*((x-x2)^2+(y-y2)^2))/dmax+1.0);

return;
end

%% plot contour
x = linspace(50,250);
y = linspace(0,200);
% subs(Qs, x1 = 100, y1 = 100, x2 = 175, y2 = 100, dmax = 100^4/5);