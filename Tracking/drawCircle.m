function drawCircle(x,y,r,axHand)
%DRAWCIRCLE draws a circle of the indicated radius and centre on the given
%axes handles. Based on code originally given here:
%https://uk.mathworks.com/matlabcentral/answers/3058-plotting-circles
%
%   INPUTS:
%       -x: X-coordinate of circle centre
%       -y: Y-coordinate of circle centre
%       -r: Radius of circle
%       -axHand: Handle to axes on which you want this circle to be drawn
%   
%   Authors: Paolo Silva (c) 2011, Oliver J. Meacock (c) 2019

ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(axHand,x+xp,y+yp,'b--');
end