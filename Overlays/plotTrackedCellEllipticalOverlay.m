function [] = plotTrackedCellEllipticalOverlay(Tracks,overlaySettings,colourMap,axHand,minData,maxData)
%PLOTTRACKEDCELLELLIPTICALOVERLAY creates an overlay in the specified axes
%of elliptical reconstructions of all objects in the currently selected
%frame. Also plots an arrow at the centroid of the object, indicating
%object motion for tracked objects.
%
%   INPUTS:
%       -Tracks: track data, generally procTracks from the Tracks.mat file
%       produced by the tracking module
%       -overlaySettings: settings specifying e.g. the selected frame to
%       display. Generated automatically by the overlayTester GUI
%       -colourmap: string specifying identity of colourmap to use to colour
%       masks
%       -axHand: handle to the axes you wish to plot overlay into
%       -minData: value of lowest value of selected data field across all
%       tracks and times
%       -minData: value of greatest value of selected data field across all
%       tracks and times
%
%   Author: Oliver J. Meacock, (c) 2019

maxVmag = 0;
for i = 1:size(Tracks,2)
    if max(Tracks(i).vmag) > maxVmag
        maxVmag = max(Tracks(i).vmag);
    end
end

cmap = colormap(overlaySettings.cmapName);

%Find indicies of all tracks present during this time point, and position of this time point within these tracks
for cInd = 1:length(Tracks)
    tInd = find(Tracks(cInd).times == overlaySettings.showFrame + overlaySettings.frameOffset + 1);
    
    if ~isempty(tInd)
        if strcmp(overlaySettings.info,'Data')
            if tInd > size(Tracks(cInd).(overlaySettings.data),1)
                thisDat = Tracks(cInd).(overlaySettings.data)(end);
            else
                thisDat = Tracks(cInd).(overlaySettings.data)(tInd);
            end
            thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
            if thisInd == 0
                thisInd = 1;
            end
            thisCol = cmap(thisInd,:);
            
            plotCellOnPicture(Tracks,tInd,cInd,thisCol,overlaySettings.pixSize,(overlaySettings.pixSize/maxVmag)*30,2,axHand)
        else
            plotCellOnPicture(Tracks,tInd,cInd,colourMap(cInd,:),overlaySettings.pixSize,(overlaySettings.pixSize/maxVmag)*30,2,axHand)
        end
    end
end 