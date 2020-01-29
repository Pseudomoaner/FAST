function [Orientation,Length,Width] = rotationMeasuresMaxPerimDist(segImg)
%ROTATIONMEASURESMAXPERIMDIST measures morphological properties of the 
%object found in the segImg binary image. Uses an exhaustive algorithm to
%find the pair of points around the boundary that are the furthest apart,
%and the pair that are the closest.
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
[yBound,xBound] = ind2sub(size(segImgBound),find(segImgBound));

%By using the topmost point, can ensure that first step must be downwards
%('South')
[~,maxYind] = max(yBound);
stPnt = [yBound(maxYind),xBound(maxYind)];

perim = bwtraceboundary(segImg,stPnt,'S');

dists = pdist2(perim,perim);

[maxs,maxRs] = max(dists,[],1);
[Length,maxC] = max(maxs,[],2);
maxR = maxRs(maxC);

%We define the width as the shortest distance between two points not in the
%'quarter diagonal' (the diagonal corresponding to boundary locations less
%than quarter of a cell perimeter away from the current point).
nanedDists = dists;
for i = 1:size(dists,1)
    for j = 1:size(dists,2)
        if abs(i-j) <= floor(size(dists,1)/4) || abs(i-j) >= floor(3*size(dists,1)/4)
            nanedDists(i,j) = NaN;
        end
    end
end

Width = nanmin(nanedDists(:));

dispX = perim(maxR,2)-perim(maxC,2);
dispY = perim(maxR,1)-perim(maxC,1);

Orientation = atand(dispY/dispX);