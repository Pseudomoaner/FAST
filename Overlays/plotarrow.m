function plotarrow(x,y,u,v,color,scale,axHand)
%PLOTARROW draws an arrow of the specified location, dimensions and colour
%in the specified axes. 
%
%   INPUTS:
%       -x: X-coordinate of the origin of the arrow, typically in pixels
%       (rather than physical units)
%       -y: Y-coordinate of the origin of the arrow, typically in pixels
%       (rather than physical units)
%       -u: X-component of the 'displacement' of the (basal) arrow. Is
%       scaled by the scale parameter when it comes to actually drawing the
%       arrow.
%       -v: Y-component of the 'displacement' of the (basal) arrow. Is
%       scaled by the scale parameter when it comes to actually drawing the
%       arrow.
%       -color: RGB triple indicating the colour you want the arrow to be
%       -scale: Parameter allowing you to change the size of the arrow.
%       Allows you to e.g. increase the size of arrows indicating small
%       motions in a consistent fashion.
%       -axHand: Handle to the axes into which you want this arrow to be
%       overlaid.
%   
%   Author: Oliver J. Meacock (c) 2019

alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length

u = u*scale;
v = v*scale;
uu = [x;x+u;NaN];
vv = [y;y+v;NaN];
h1 = line(uu(:),vv(:),'Color',color,'LineWidth',2,'Parent',axHand);
hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
    x+u-alpha*(u-beta*(v+eps));NaN];
hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
    y+v-alpha*(v+beta*(u+eps));NaN];
h2 = line(hu(:),hv(:),'Color',color,'LineWidth',2,'Parent',axHand);