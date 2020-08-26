function [] = runTrackingBatch(root,trackSettings)
%RUNTRACKINGBATCH applies the specified track settings to the dataset
%located in the root directory.
%
%   INPUTS:
%       -root: String defining the location of the target root
%       directory.
%       -trackSettings: Settings structure generated by the FAST GUI.
%       Typically stored within the 'Tracks.mat' file of a given dataset.
%
%   Author: Oliver J. Meacock (c) 2019

tracksPath = [root,filesep,'Tracks.mat'];
cellFeaturesPath = [root,filesep,'cellFeatures.mat'];

load(cellFeaturesPath)

%Get the feature statistics and formatted feature matrices
[linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet);

%Do the actual tracking
[Tracks,Initials] = doDirectLinkingRedux(featMats.lin,featMats.circ,featMats.lin,featMats.circ,linkStats,trackSettings.gapWidth,false,0,debugSet);

progressbar(0);

trackDataNames = fieldnames(trackableData);
rawTracks = struct();
for i = 1:size(trackDataNames,1)
    if i == 1
        [rawTracks.(trackDataNames{i}),trackTimes,rawToMappings,rawFromMappings] = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),true);
    else
        rawTracks.(trackDataNames{i}) = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),true);
    end
    progressbar(i/size(trackDataNames,1));
end

%This bit of code adds on the time cut off from the start of the imaging sequence by the user during frame selection. Might not be what the end user wants, but they can always take this number off again if they want.
%Does make later bits of code (e.g. loading the image files for underlays) simpler.
for i = 1:size(trackTimes,2)
    trackTimes{i} = trackTimes{i} + trackSettings.minFrame - 1;
end

[procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,true);
save(tracksPath,'procTracks','rawFromMappings','rawToMappings','rawTracks','trackTimes','toMappings','fromMappings','trackSettings','trackableData','linkStats','-v7.3')

end