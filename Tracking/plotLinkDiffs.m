function [] = plotLinkDiffs(linkDiffs,linkStats,xInd,yInd,incRad,axHand)
%PLOTLINKDIFFS plots the normalised displacement space for the currently
%selected pair of features and the currently selected test frame. Also
%indicates the currently selected adaptive link threshold as a blue circle.
%
%   INPUTS:
%       -linkDiffs: Structure containing the normalised displacements of
%       all objects between the currently selected pair of frames (A/B).
%       Split into accepted and rejected fields, which are packaged forms
%       of the output of doDirectLinkingRedux.
%       -linkStats: The statistics of the currently selected features,
%       extracted by the gatherLinkStats function during the model training
%       stage of the tracking algorithm.
%       -xInd: The column in the linkDiffs.accept/reject matrix that should
%       be plotted as the x-values in the 2D normalised displacement space
%       plot. Determined by the user choice of the x popupmenu in the GUI
%       -yInd: The column in the linkDiffs.accept/reject matrix that should
%       be plotted as the y-values in the 2D normalised displacement space
%       plot. Determined by the user choice of the y popupmenu in the GUI
%       -incRad: The currently selected inclusion radius, based on the
%       current trackability of the dataset and the choice of the adaptive
%       linking threshold. Will be plotted as a blue dashed circle.
%       -axHand: Handle to the axes on which normalised displacement space
%       should be plotted.
%
%   Author: Oliver J. Meacock (c) 2019

cla(axHand)
Rs = [linkStats.linRs,linkStats.circRs];

if ~isempty(linkDiffs.accept)
    plot(axHand,linkDiffs.accept(:,xInd),linkDiffs.accept(:,yInd),'b.');
end
hold(axHand,'on')
if ~isempty(linkDiffs.reject)
    plot(axHand,linkDiffs.reject(:,xInd),linkDiffs.reject(:,yInd),'r.');
end

drawCircle(0,0,incRad,axHand);

yl = ylim(axHand);
xl = xlim(axHand);
maxLim = min([max([max(yl(:)),max(xl(:))]),20]);

axis(axHand,'equal')
axis(axHand,[-maxLim,maxLim,-maxLim,maxLim])

axHand.XAxisLocation = 'origin';
axHand.YAxisLocation = 'origin';

legend(axHand,'Accepted links','Rejected links','Threshold')

hold(axHand,'off')