function bwridge = bwRidgeCenterMod(I,  scales, valuethresh)
%BWRIDGECENTERMOD locates ridges of a given scale in an input grayscale
%image.
%
%   INPUTS:
%       -I: The input image, as a matrix of double values.
%       -scales: The scale (width) of ridges you wish to find in I, in
%       pixels. Can be given as a vector of values, in which case a sort of
%       'maximal' ridge magnitude will be calculated across all scales.
%       -valuethresh: The threshold eigenvalue magnitude used to determine
%       the location of ridges
%
%   OUTPUTS:
%       -bwridge: Binary image of ridges in I.
%
%   Authors: Joeseph Harvey (c) 2014 and Oliver J. Meacock (c) 2019

%% extract the centerline of scale-space valleys
M_mag = im_scalablehess2(I, scales);
if isempty(valuethresh)
    valuethresh = graythresh( M_mag );
end
bwridge = im2bw( M_mag, valuethresh );
