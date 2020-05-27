function [] = plotNormalizedStepSizes(trackSettings,linkDiffs,linkStats,axHand)
%PLOTNORMALISEDSTEPSIZES plots the normalised displacement space for the currently
%selected pair of features and the currently selected test frame. Also
%indicates the currently selected adaptive link threshold as a blue circle.
%Calls plotLinkDiffs to do most of the heavy plotting, most of this
%function is concerned with figuring out where the user-selected data is
%stored.
%
%   INPUTS:
%       -trackSettings: Structure containing the settings selected by the
%       user within the diffusionTracker GUI. In particular, contains
%       information about features currently in use during model training
%       phase and which of these should be plotted in the normalised
%       displacement space window.
%       -linkDiffs: Repackaged output of the doDirectLinkingRedux
%       function, contains accepted and rejected links for the currently
%       selected test frame.
%       -linkStats: Output of teh gatherLinkStats function, contents is
%       used for normalising the displacement space.
%       -axHand: Handle to axes in which the normalised displacement space
%       should be plotted.
%
%   Author: Oliver J. Meacock (c) 2019

xString = trackSettings.xString;
yString = trackSettings.yString;

featureStruct = prepareTrackStruct(trackSettings);

featureNames = fieldnames(featureStruct);

%Find the location of the data corresponding to the requested x-axis in the feature matrices
centInds = find(cellfun(@(x) strcmp(x,'Centroid'),featureNames));
veloInds = find(cellfun(@(x) strcmp(x,'Velocity'),featureNames));
areaInds = find(cellfun(@(x) strcmp(x,'Area'),featureNames));
lengInds = find(cellfun(@(x) strcmp(x,'Length'),featureNames));
widtInds = find(cellfun(@(x) strcmp(x,'Width'),featureNames));
orieInds = find(cellfun(@(x) strcmp(x,'Orientation'),featureNames));
chmeInds = find(cellfun(@(x) strcmp(x,'ChannelMean'),featureNames));
chstInds = find(cellfun(@(x) strcmp(x,'ChannelStd'),featureNames));
spf1Inds = find(cellfun(@(x) strcmp(x,'SpareFeat1'),featureNames));
spf2Inds = find(cellfun(@(x) strcmp(x,'SpareFeat2'),featureNames));
spf3Inds = find(cellfun(@(x) strcmp(x,'SpareFeat3'),featureNames));
spf4Inds = find(cellfun(@(x) strcmp(x,'SpareFeat4'),featureNames));

if ~isempty(orieInds) %Special case, as Orientations is a circular statistic. Gets tagged onto the end of the linkDiffs columns, no matter where it is.
    if ~isempty(centInds) && orieInds < max(centInds)
        centInds = centInds - 1;
    end
    if ~isempty(veloInds) && orieInds < max(veloInds)
        veloInds = veloInds - 1;
    end
    if ~isempty(areaInds) && orieInds < max(areaInds)
        areaInds = areaInds - 1;
    end
    if ~isempty(lengInds) && orieInds < max(lengInds)
        lengInds = lengInds - 1;
    end
    if ~isempty(widtInds) && orieInds < max(widtInds)
        widtInds = widtInds - 1;
    end
    if ~isempty(chmeInds) && orieInds < max(chmeInds)
        chmeInds = chmeInds - 1;
    end
    if ~isempty(chstInds) && orieInds < max(chstInds)
        chstInds = chstInds - 1;
    end
    if ~isempty(spf1Inds) && orieInds < max(spf1Inds)
        spf1Inds = spf1Inds - 1;
    end
    if ~isempty(spf2Inds) && orieInds < max(spf2Inds)
        spf2Inds = spf2Inds - 1;
    end
    if ~isempty(spf3Inds) && orieInds < max(spf3Inds)
        spf3Inds = spf3Inds - 1;
    end
    if ~isempty(spf4Inds) && orieInds < max(spf4Inds)
        spf4Inds = spf4Inds - 1;
    end
    orieInds = max([centInds,veloInds,areaInds,lengInds,widtInds,chmeInds,chstInds,spf1Inds,spf2Inds,spf3Inds,spf4Inds]) + 1;
end

%sortList is the order of features as they will occur in the linkDiffs.accept/reject matrices (columnwise)
[~,sortList] = sort([centInds,veloInds,areaInds,lengInds,widtInds,chmeInds,chstInds,spf1Inds,spf2Inds,spf3Inds,spf4Inds,orieInds]);

popupStrings = {};
popupInd = 1;

if ~isempty(centInds)
    popupStrings{popupInd} = {'d(x)';'d(y)'};
    popupInd = popupInd + 1;
end
if ~isempty(veloInds)
    popupStrings{popupInd} = {'d(Vx)';'d(Vy)'};
    popupInd = popupInd + 1;
end
if ~isempty(areaInds)
    popupStrings{popupInd} = {'d(Area)'};
    popupInd = popupInd + 1;
end
if ~isempty(lengInds)
    popupStrings{popupInd} = {'d(Length)'};
    popupInd = popupInd + 1;
end
if ~isempty(widtInds)
    popupStrings{popupInd} = {'d(Width)'};
    popupInd = popupInd + 1;
end
if ~isempty(chmeInds)
    chmeNames = {};
    for chan = trackSettings.MeanInc'
        chmeNames = [chmeNames;['d(Channel ',num2str(chan),' intensity)']];
    end
    popupStrings{popupInd} = chmeNames;
    popupInd = popupInd + 1;
end
if ~isempty(chstInds)
    chstNames = {};
    for chan = trackSettings.StdInc'
        chmeNames = [chstNames;['d(Channel ',num2str(chan),' variation)']];
    end
    popupStrings{popupInd} = chstNames;
    popupInd = popupInd + 1;
end
if ~isempty(spf1Inds)
    popupStrings{popupInd} = {'d(SpareFeat1)'};
    popupInd = popupInd + 1;
end
if ~isempty(spf2Inds)
    popupStrings{popupInd} = {'d(SpareFeat2)'};
    popupInd = popupInd + 1;
end
if ~isempty(spf3Inds)
    popupStrings{popupInd} = {'d(SpareFeat3)'};
    popupInd = popupInd + 1;
end
if ~isempty(spf4Inds)
    popupStrings{popupInd} = {'d(SpareFeat4)'};
    popupInd = popupInd + 1;
end
if ~isempty(orieInds)
    popupStrings{popupInd} = {'d(Orientation)'};
    popupInd = popupInd + 1;
end

featNameSortedArray = {};
for i = 1:size(sortList,2)
    featNameSortedArray = [featNameSortedArray;popupStrings{sortList(i)}];
end

%Now you have an array of all the strings in the popup menu, indexed according to how they appear in the feature matices. Check where the selected strings feature.
xInd = find(cellfun(@(x) strcmp(x,xString),featNameSortedArray));
yInd = find(cellfun(@(x) strcmp(x,yString),featNameSortedArray));

incRad = linkStats.incRads(trackSettings.frameA-trackSettings.minFrame+1);

if ~isempty(xInd) && ~isempty(yInd)
    plotLinkDiffs(linkDiffs,linkStats,xInd,yInd,incRad,axHand)
end

axHand.Box = 'on';
axHand.LineWidth = 1.5;
