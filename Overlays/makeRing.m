function P = makeRing(axH,cX,cY,iR,oR,cVec)
%MAKERING is similar to drawCircleOnImg, but draws a ring of the
%specified dimensions rather than a circle. Also draws as an overlay rather
%than directly into the pixels of the image.
%
%   INPUTS:
%       -axH: axis handle to plot to
%       -[cX,cY]: coordinates of ring centre
%       -[iR,oR]: radius of inner and outer rims of ring, respectively
%       -cVec: vector specifying colour of ring as an rgb triplet
%
%   Author: Oliver J. Meacock, (c) 2019
%
%Some code originally from here: https://uk.mathworks.com/matlabcentral/answers/3540-ring-annulis-patch

t = linspace(0,2*pi,200);
x = cX + iR*cos(t);
y = cY + iR*sin(t);
X = cX + oR*cos(t);
Y = cY + oR*sin(t);
P = patch(axH,[x X],[y Y],cVec,'linestyle','non');