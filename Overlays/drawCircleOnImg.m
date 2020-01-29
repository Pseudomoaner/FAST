function [rCh,gCh,bCh] = drawCircleOnImg(x,y,rad,rCh,gCh,bCh,colVec)
%DRAWCIRCLEONIMG draws a (filled) circle of the specfied dimensions onto the input
%image channels.
%
%   INPUTS: 
%       -[x,y] = coordinates of circle centre
%       -rad = radius of circle
%       -[rCh,gCh,bCh] = input image separated into rgb planes
%       -colVec = vector specifying colour of circle as an rgb triplet
%
%   OUTPUTS:   
%       -[rCh,gCh,bCh] = input image with circle drawn on top
%
%   Author: Oliver J. Meacock (c) 2019

[xGrid,yGrid] = meshgrid(1:size(rCh,2),1:size(rCh,1));

circInds = sqrt((xGrid - x).^2 + (yGrid - y).^2) < rad;

rCh(circInds) = colVec(1);
gCh(circInds) = colVec(2);
bCh(circInds) = colVec(3);