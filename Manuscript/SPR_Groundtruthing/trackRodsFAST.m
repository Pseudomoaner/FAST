function [procTracks,fromMappings,toMappings,trackSettings,linkStats,Tracks] = trackRodsFAST(trackableData,pS,dt)
%TRACKRODSFAST applies the FAST tracking algorithm to the input
%trackableData feature structure using the specified processing settings.
%This is similar to the tracking routine used in FAST, but has been
%customised to be compatible with the SPR simulation framework.
%
%   INPUTS:
%       -trackableData: The slice representation of your feature data, as
%       output by the SPR simulation.
%       -pS: The processing settings to be applied to this data.
%       -dt: The timestep size between frames.
%
%   OUTPUTS:
%       -procTracks: Structure containing sequential chains of feature
%       information for each reconstructued track.
%       -toMappings and fromMappings provide the mappings to and from the
%       track representation and the frame representation. In the case of
%       this function, the following expressions should be true:
%
%           data{a}(b) = dataTracks{toMappings{a}(b,1)}(toMappings{a}(b,2))
%           dataTracks{c}(d) = data{fromMappings{c}(d,1)}(fromMappings{c}(d,2))
%       
%       -trackSettings: The settings used to generate these tracks (usually
%       stored in the diffusionTracker GUI)
%       -linkStats: The summary statisitcs of the collection of features
%       (covariance matrices, averages etc).
%       -Tracks: The cell-array-based version of the tracks, equivalent to
%       the output of doDirectLinkingRedux. More readily amenable to direct
%       comparison to the SPR ground truth than other formats.
%
%   Author: Oliver J. Meacock, 2022

trackSettings.SpareFeat1 = 0;
trackSettings.Centroid = pS.Centroid;
trackSettings.Orientation = pS.Orientation;
trackSettings.Velocity = 0;
trackSettings.Length = pS.Length;
trackSettings.Area = pS.Area;
trackSettings.Width = pS.Width;
trackSettings.noChannels = pS.noChannels;
trackSettings.availableMeans = pS.availableMeans;
trackSettings.availableStds = pS.availableStds;
trackSettings.MeanInc = pS.meanInc;
trackSettings.StdInc = pS.stdInc;
trackSettings.SpareFeat2 = 0;
trackSettings.SpareFeat3 = 0;
trackSettings.SpareFeat4 = 0;

trackSettings.incProp = pS.incProp;
trackSettings.tgtDensity = pS.tgtDensity;
trackSettings.gapWidth = pS.gapWidth;
trackSettings.maxFrame = size(trackableData.Centroid,2);
trackSettings.minFrame = 1;
trackSettings.minTrackLen = pS.minTrackLength;
trackSettings.frameA = 1;
trackSettings.statsUse = pS.statsUse;
trackSettings.pseudoTracks = false; %Variable set to true in extractFeatureEngine.m if the 'tracks' have come from a single frame.

trackSettings.dt = dt;
trackSettings.pixSize = pS.pixSize;
trackSettings.maxX = pS.fieldWidth;
trackSettings.maxY = pS.fieldHeight;
trackSettings.maxF = trackSettings.maxFrame;

debugSet = true; %Prevents modal locking of progress bars

[linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet);

%Build feature matrices
[featMats.lin,featMats.circ] = buildFeatureMatricesRedux(trackableData,featureStruct,possIdx,trackSettings.minFrame,trackSettings.maxFrame);

[Tracks,Initials] = doDirectLinkingRedux(featMats.lin,featMats.circ,featMats.lin,featMats.circ,linkStats,trackSettings.gapWidth,false,debugSet);

trackDataNames = fieldnames(trackableData);
rawTracks = struct();
for i = 1:size(trackDataNames,1)
    if i == 1
        [rawTracks.(trackDataNames{i}),trackTimes,rawToMappings,rawFromMappings] = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),true);
    else
        rawTracks.(trackDataNames{i}) = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),false);
    end
end

[procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);