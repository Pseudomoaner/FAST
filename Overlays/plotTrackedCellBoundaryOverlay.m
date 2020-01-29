function [] = plotTrackedCellBoundaryOverlay(tracks,overlaySettings,colourmap,bfImg,segPath,axHand,minData,maxData)
%PLOTTRACKEDCELLBOUNDARYOVERLAY plots the segmentation boundaries of the selected
%frame for all objects at the specified time.
%
%   INPUTS:
%       -tracks: track data
%       -overlaySettings: settings specifying e.g. the selected frame to
%       display
%       -colourmap: string specifying identity of colourmap to use to colour
%       masks
%       -bfImg: matrix containing underlay image in grayscale
%       -segPath: string specifying path to segmentation image3
%       axHand: handle to axes to plot to
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
imgOut = plotBoundaryOnPicture(segment,bfImg3,tracks,overlaySettings.showFrame + overlaySettings.frameOffset + 1,overlaySettings.pixSize,overlaySettings,colourmap,minData,maxData);

imshow(imgOut,'Parent',axHand)