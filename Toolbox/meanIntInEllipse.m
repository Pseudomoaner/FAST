function [meanInt,total] = meanIntInEllipse(img,procTrack,ind,pxSize)
%MEANINTINELLIPSE returns the average and total pixel intensity within the
%specified ellipse in the given image.
%
%   INPUTS:
%       -img: the original image for the ellipse to be cut from.
%       -procTrack: a single track from a larger procTracks structure.
%       Should contain majorLen, minorLen, x, y and phi
%       fields, corresponding to 'Length', 'Width', 'Position' and 
%       'Orientation' in the feature extraction module.
%       -ind: the track timepoint containing the ellipse parameters you 
%       want to draw your mask with.
%       -pxSize: the side length of a single pixel. Found in the
%       metadata structure if FAST's image inport has been used.
%
%   OUTPUTS:
%       -mean: The average intensity of pixels within the ellipse
%       specified.
%       -total: The total intensity of pixels within the ellipse specified.
%
%   Author: Oliver J. Meacock

%Rescale ellipse parameters
xPx = round(procTrack.x(ind)/pxSize);
yPx = round(procTrack.y(ind)/pxSize);
minLenPx = round(procTrack.minorLen(ind)/pxSize);
majLenPx = round(procTrack.majorLen(ind)/pxSize);
phi = procTrack.phi(ind);

halfWindow = majLenPx*2;

%Generate a cut out bit of the coordinate grid for calculating the ellipse
%over.
[xGrid,yGrid] = meshgrid(round(xPx)-halfWindow:round(xPx)+halfWindow,round(yPx)-halfWindow:round(yPx)+halfWindow);

minX = max(1,round(xPx)-halfWindow);
maxX = min(size(img,2),round(xPx)+halfWindow);
minY = max(1,round(yPx)-halfWindow);
maxY = min(size(img,1),round(yPx)+halfWindow);

imgSmall = img(minY:maxY,minX:maxX);

%Transform x and y grids into canonical coordinates.
xCan = (xGrid-xPx)*cosd(-phi) + (yGrid-yPx)*sind(-phi);
yCan = -(xGrid-xPx)*sind(-phi) + (yGrid-yPx)*cosd(-phi);

geometry = ((xCan.^2)/(majLenPx^2)) + ((yCan.^2)/(minLenPx^2));

mask = geometry < 3; %Full disclosure - this should be a 1 in principle, but this just makes things that bit wider.
mask = mask(1:maxY-minY+1,1:maxX-minX+1);

imgSmall(mask == 0) = 0;
total = sum(imgSmall(:));
meanInt = total/sum(mask(:));