function imgOut = plotTrackedCellMaskOverlay(tracks,overlaySettings,colourmap,bfImg,segPath,axHand,minData,maxData)
%PLOTTRACKEDCELLMASKOVERLAY plots the masks (segmentations) of the selected
%frame for all objects at the specified time.
%
%   INPUTS:
%       -tracks: track data, generally procTracks from the Tracks.mat file
%       produced by the tracking module
%       -overlaySettings: settings specifying e.g. the selected frame to
%       display. Generated automatically by the overlayTester GUI
%       -colourmap: string specifying identity of colourmap to use to colour
%       masks
%       -bfImg: matrix containing underlay image in grayscale
%       -segPath: string specifying path to segmentation image
%       -axHand: handle to axes for plot into
%       -minData: value of lowest value of selected data field across all
%       tracks and times
%       -minData: value of greatest value of selected data field across all
%       tracks and times
%
%   Author: Oliver J. Meacock, (c) 2019
   
%Convert to RGB
bfImg3 = repmat(bfImg,[1,1,3]);

%Read segmentation
segment = imread([segPath,sprintf('Frame_%04d.tif',overlaySettings.showFrame + overlaySettings.frameOffset)]);
segment = bwlabel(segment);

%Shunting this work to another function isn't strictly necessary (or
%clean), but it's evolved this way and it works so I'm not over eager to
%change it
imgOut = plotMaskOnPicture(segment,bfImg3,tracks,overlaySettings.showFrame + overlaySettings.frameOffset + 1,overlaySettings.pixSize,overlaySettings,colourmap,minData,maxData);

imshow(imgOut,'Parent',axHand)