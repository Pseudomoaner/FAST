function [Orientation,Length,Width] = rotationMeasures(segImg)
%ROTATIONMEASURES measures morphological properties of the 
%object found in the segImg binary image using ellipse fitting.
%
%   INPUTS:
%       -segImg: Binary image of a white object on a black background.
%
%   OUPUTS:
%       -Orientation: Orientation of long axis of object in degrees
%       -Length: Length of long axis of object in pixels
%       -Width: Width of short axis of object in pixels
%
%   Author: Oliver J. Meacock, (c) 2019

segImgBound = bwmorph(segImg,'remove');

[x,y] = ind2sub(size(segImgBound),find(segImgBound));

elFit = fit_ellipse(x,y);

if ~isempty(elFit.phi)
    Orientation = mod(rad2deg(elFit.phi)+180,180)-90;
    Length = elFit.long_axis;
    Width = elFit.short_axis;
else
    Orientation = NaN;
    Length = NaN;
    Width = NaN;
end