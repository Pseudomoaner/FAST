%This script uses various functions from FAST's post-processing toolbox to
%quickly filter data, assign species identities based on fluorescence and
%find T6SS firing events.

clear all
close all

%File choice
mainRoot = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\'; %Main directory in which all of your datasets is located
branches = {'SM6_1','SM6_2','SM7_1','SM7_2'}; %Names of subdirectories within main directory in which each separate dataset is stored
batchRoots = fullfile(mainRoot,branches);

%Pre-initalise data structures
trackSettingsAll = struct();
trackableDataAll = struct();
procTracksConc = [];
procTrackLims = 1;

for r = 1:size(branches,2)
    load(fullfile(batchRoots{r},'Tracks.mat'))

    for i = 1:size(procTracks,2)
        procTracks(i).event = zeros(size(procTracks(i).event));
    end

    %Filter data (remove objects that don't look like cells)
    procTracks = filterTracks(procTracks,'minorLen',0.5,-1);
    procTracks = filterTracks(procTracks,'minorLen',1.2,1);
    procTracks = filterTracks(procTracks,'vmag',0.02,1);
    procTracks = filterTracks(procTracks,'majorLen',5,1);
    procTracks = filterTracks(procTracks,'majorLen',1.5,-1);

    %Concatenate results
    trackSettingsAll.(branches{r}) = trackSettings;
    trackableDataAll.(branches{r}) = trackableData;
    procTracksConc = [procTracksConc,procTracks];
    procTrackLims = [procTrackLims,procTrackLims(r) + size(procTracks,2)];
end

%We will have two versions of the same data. The first will contain data
%concatenated across all conditions that can be visualised using the
%Plotting module (at least with certain plotting options, like the joint
%distribution and the histograms). The second will contain more
%human-friendly data, sorted by experiment name.

%Split popululations by fluorescence
procTracksConc = SplitFluoPopulationsTracks(procTracksConc,2,3);

%Detect firing events
procTracksConc = labelUnusualEvents(procTracksConc,[],'channel_3_std',2,1);

procTracks = procTracksConc; %Need to rename so you can use FAST's plotting functions easily

save(fullfile(mainRoot,'Tracks.mat'),'procTracks','trackSettings') %Assuming track settings are the same for all datasets.

%Split the compiled tracks into more user-friendly substructures
procTracksAll = struct();
for r = 1:size(branches,2)
    procTracksAll.(branches{r}) = procTracksConc(procTrackLims(r):procTrackLims(r+1)-1);
end

save(fullfile(mainRoot,'allTracks.mat'),'procTracksAll','trackableDataAll','trackSettingsAll')