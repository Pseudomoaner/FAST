function [] = plotTrackedCellSegmentedOverlay(data,imPaths,segPaths,outPaths,pixSize)
%PLOTTRACKEDCELLSEGMENTEDOVERLAY provides the visualisation of the test
%tracking process. Saves two images, allowing user-friendly interpretation
%of the test-tracking process.
%
%   INPUTS:
%       -data: Equivalent to procTracks, the output of the processTracks.m
%       function. Contains all track data.
%       -imPaths: Cell array with two elements, containing the paths where
%       each of the two underlay images can be found.
%       -segPaths: Cell array with two elements, containing the paths where
%       each of the two segmentation images can be found.
%       -outPaths: Cell array with two elements, containing the paths where
%       the two output images should be saved.
%       -pixSize: The physical size of pixels in this dataset.
%
%   Author: Oliver J. Meacock (c) 2019

%Begin by assigning each track a different (random) colour
colVecs = [zeros(size(data,2),1),rand(size(data,2),2)];

for i = 1:2
    imgPlane = -double(imread(imPaths{i}));
    
    %Normalize image plane
    normImgPlane = (imgPlane - min(imgPlane(:)))/(max(imgPlane(:))-min(imgPlane(:)));
    
    %Convert to RGB
    normImgPlane = repmat(normImgPlane,[1,1,3]);
    
    %Read segmentation
    segment = imread(segPaths{i});
    segment = bwlabel(segment);
    
    imgOut = plotSegmentationOnPicture(segment,normImgPlane,data,i,pixSize,colVecs);
    
    imwrite(imgOut,outPaths{i})
end