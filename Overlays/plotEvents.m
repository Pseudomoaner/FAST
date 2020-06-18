function [] = plotEvents(tracks,overlaySettings,axHand)
%PLOTEVENTS draws rings of different colours around different classes of
%event. For more information on events and how to define them, see https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:advanced_usage#population_and_event_labelling
%
%   INPUTS:
%       -tracks: Object track data, typically the procTracks structure
%       saved within the Tracks.mat file.
%       -overlaySettings: User-specified overlay settings, defined with the
%       overlyTester GUI
%       -axHand: Handle to the axes into which you want to plot the
%       event-indicating rings.
%
%   Author: Oliver J. Meacock (c) 2019

f = overlaySettings.showFrame+1;

ringThick = 5; %Thickness of plotted ring (in pixels)
innerOffset = 10; %Offset of inner rim of ring from the cell profile (in pixels)

for cInd = 1:size(tracks,2)
    tInd = find(tracks(cInd).times == f);
    if ~isempty(tInd)
        innerRad = round(tracks(cInd).majorLen(tInd)/(overlaySettings.pixSize*2)) + innerOffset;
        tracks(cInd).event(tInd)
        switch tracks(cInd).event(tInd)
            case 1
                makeRing(axHand,tracks(cInd).x(tInd)/overlaySettings.pixSize,tracks(cInd).y(tInd)/overlaySettings.pixSize,innerRad,innerRad + ringThick,[1,0,0]);
            case 2
                makeRing(axHand,tracks(cInd).x(tInd)/overlaySettings.pixSize,tracks(cInd).y(tInd)/overlaySettings.pixSize,innerRad,innerRad + ringThick,[0,1,1]);
            case 3
                makeRing(axHand,tracks(cInd).x(tInd)/overlaySettings.pixSize,tracks(cInd).y(tInd)/overlaySettings.pixSize,innerRad,innerRad + ringThick,[0.7,0,1]);
        end
    end
end