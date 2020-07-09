function [] = terminateCorrection(src,evt,handles,trackSettings,root,debugSet)
%TERMINATECORRECTION is a function that is called when the track correction
%GUI is closed. Does a bit of housekeeping to update and save tracking data
%once the user has finished correcting it (don't do this on the fly as it's
%quite slow).
%
%   INPUTS:
%       -src: not used
%       -evt: not used
%       -handles: Structure containing the handles to the various elements
%       of the parental diffusion tracker GUI
%       -trackSettings: User defined settings defined within the diffusion
%       tracker GUI
%       -root: String defining the path to the current root directory
%       -debugSet: Set true if FAST is currently in debug mode
%
%   Author: Oliver J. Meacock (c) 2019

debugprogressbar([0;0;0],debugSet)

load([root,filesep,'Tracks.mat'],'rawTracks','rawFromMappings','rawToMappings','trackTimes')

trackDataNames = fieldnames(rawTracks);

[procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);
plotTrackLengthDistribution(rawTracks.(trackDataNames{1}),handles.axes3,trackSettings.minTrackLen)

save([root,filesep,'Tracks.mat'],'procTracks','fromMappings','toMappings','-append')

if exist(fullfile(root,'Pre-division_Tracks.mat'),'file')
    save(fullfile(root,'Pre-division_Tracks.mat'),'procTracks','fromMappings','toMappings','-append')
end

debugprogressbar([1;1;1],debugSet)
