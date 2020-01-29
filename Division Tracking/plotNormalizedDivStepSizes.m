function [] = plotNormalizedDivStepSizes(divisionSettings,linkDiffs,linkStats,axHand)
%PLOTNORMALIZEDDIVSTEPSIZES plots the normalised displacement space for the
%currently selected pair of features for the entire dataset. Also
%indicates the currently selected adaptive link threshold as a blue circle.
%Calls plotLinkDiffs to do most of the heavy plotting, most of this
%function is concerned with figuring out where the data selected by the
%user using the two popup menus is stored.
%
%   INPUTS:
%       -divisionSettings: User-defined settings structure, set up using
%       the Division Tracker GUI
%       -linkDiffs: The displacements between nearest neighbours in the
%       normalised feature space. Includes two fields, one indicating the
%       displacement of accepted links (.accept) and one indicating the 
%       displacement of rejected links (.reject).
%       -linkStats: The summary statistics of the features currently used
%       in the division detection algorithm. Generated during the model
%       training stage of the algorithm.
%       -axHand: Handle to the axes into which the final plot should be
%       placed.
%
%   Author: Oliver J. Meacock (c) 2019

xString = divisionSettings.xString;
yString = divisionSettings.yString;

featureStruct = prepareTrackStruct(divisionSettings);

featureNames = fieldnames(featureStruct);

%Find the location of the data corresponding to the requested x-axis in the feature matrices
timeInds = 1; %Because of the way division detection is set up, 'd(t)' ALWAYS comes in  the first column of the feature matrices.
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
[~,sortList] = sort([timeInds,centInds,veloInds,areaInds,lengInds,widtInds,chmeInds,chstInds,spf1Inds,spf2Inds,spf3Inds,spf4Inds,orieInds]);

popupStrings = {'d(t)'}; %Because of the way division detection is set up, 'd(t)' ALWAYS comes in  the first column of the feature matrices.
popupInd = 2;

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
    for chan = 1:divisionSettings.Channels
        chmeNames = [chmeNames;['d(Channel ',num2str(chan),' intensity)']];
    end
    popupStrings{popupInd} = chmeNames;
    popupInd = popupInd + 1;
end
if ~isempty(chstInds)
    chstNames = {};
    for chan = 1:divisionSettings.Channels
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

if ~isempty(xInd) && ~isempty(yInd)
    plotLinkDiffs(linkDiffs,linkStats,xInd,yInd,divisionSettings.incRad,axHand)
end
