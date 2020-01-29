function [linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet)
%GATHERLINKSTATS performs the model training stage of the tracking
%algorithm of FAST. 
%
%   INPUTS:
%       -trackableData: One of the elements of the CellFeatures.mat file,
%       output by the tracking module. Structure containing several cell
%       arrays, each of which contains the numerical values of a specific
%       feature for all objects in the current dataset.
%       -trackSettings: Structure created by the diffusionTracker GUI
%`      -debugSet: Set true if currently in debug mode, false if not
%   
%   OUTPUTS:
%       -linkStats: The statistics extracted from the current dataset.
%       Contains separate fields indicating the Extent, Mean displacement
%       (drift), standard Deviation and Reliability of each feature over
%       time. Circular and linear features are stored separately. Also
%       contains the trackability for the entire dataset.
%       -featMats: Slightly more neatly packaged version of the output of
%       the buildFeatureMatricesRedux function
%       -featureStruct: The output of the prepareTrackStruct function
%       -possIdx: A structure containing a unique ID for each object in the
%        dataset.
%   
%   Author: Oliver J. Meacock, (c) 2019

debugprogressbar(0,debugSet);

featureStruct = prepareTrackStruct(trackSettings);

featureNames = fieldnames(featureStruct);

%Begin by building a cell array with a unique index for each possible cell
possIdx = cell(trackSettings.maxFrame - trackSettings.minFrame + 1, 1);
for i = trackSettings.minFrame:trackSettings.maxFrame
    possIdx{i - trackSettings.minFrame + 1} = 1:size(trackableData.(featureNames{1}){i},1);
end

debugprogressbar(0.2,debugSet);

%Build feature matrices
[linFeatMats,circFeatMats] = buildFeatureMatricesRedux(trackableData,featureStruct,possIdx,trackSettings.minFrame,trackSettings.maxFrame);

debugprogressbar(0.4,debugSet);

%Get scaling factors for scoring stage
[linEs,circEs,linDs,circDs,linMs,circMs,trackability] = getScalingFactors(linFeatMats,circFeatMats,trackSettings.incProp,trackSettings.statsUse);

debugprogressbar(0.8,debugSet);

%Pack up for export
featMats.lin = linFeatMats;
featMats.circ = circFeatMats;

linkStats.linEs = linEs;
linkStats.circEs = circEs;
linkStats.linDs = linDs;
linkStats.circDs = circDs;
linkStats.linMs = linMs;
linkStats.circMs = circMs;
linkStats.linRs = linEs./(4*linDs);
linkStats.circRs = circEs./(4*circDs);
linkStats.trackability = trackability;

debugprogressbar(1,debugSet);