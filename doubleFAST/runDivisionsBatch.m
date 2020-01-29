function [] = runDivisionsBatch(root,divisionSettings)

tracksPath = [root,filesep,'Tracks.mat'];

load(tracksPath)

%Get the feature statistics and formatted feature matrices
[linkStats,tgtMat,pred1Mat,pred2Mat,featureStruct,trackability] = gatherDivisionStats(procTracks,divisionSettings);

%Do the actual tracking
[linkArray1,linkArray2,acceptDiffs,rejectDiffs] = doDivisionLinkingRedux(tgtMat,pred1Mat,pred2Mat,linkStats,divisionSettings.incRad,true);

progressbar(0);

procTracks = addDivisionLinks(procTracks,linkArray1,linkArray2);

%Save a backup copy of the raw tracks if one doesn't already exist
if ~exist([root,filesep,'Pre-division_Tracks.mat'],'file')
    copyfile([root,filesep,'Tracks.mat'],[root,filesep,'Pre-division_Tracks.mat'])
end

%Update your tracks to get rid of ones that are part of small lineages
badMs = Ms(linSizes < divisionSettings.minInc);

%Generate list of tracks that are within small lineages
badTs = [];
for i = 1:size(badMs,1)
    [linInds,~] = getLineageIndices(procTracks,badMs(i),1);
    badTs = [badTs;linInds];
end
delTs = unique(badTs); %Throws in sorting for free

%Need to update the tracks the mother and daughter IDs point to.
for i = 1:size(procTracks,2)
    if ~isempty(procTracks(i).M)
        procTracks(i).M = procTracks(i).M - sum(delTs < procTracks(i).M);
    end
    if ~isempty(procTracks(i).D1)
        procTracks(i).D1 = procTracks(i).D1 - sum(delTs < procTracks(i).D1);
    end
    if ~isempty(procTracks(i).D2)
        procTracks(i).D2 = procTracks(i).D2 - sum(delTs < procTracks(i).D2);
    end
end

%Clear the relevant parts of procTracks and fromMappings
procTracks(delTs) = [];
fromMappings(delTs) = [];

%Rejigging toMappings is a bit more tricky, given the deletion of the
%tracks in the above code causes the position of tracks below them in the
%data structure to shift.
for i = delTs'-(0:(size(delTs,1)-1)) %For each short track (weird indexing here accounts for the continual subtraction of one from each track index during each run through the loop)
    %Loop through slices, deleting and reindexing if track is too short
    for j = 1:size(toMappings,1) %For each 'slice'
        currID = toMappings{j}(:,1) == i;
        bigIDs = toMappings{j}(:,1) > i;
        if sum(currID) == 1 %If this track is present at this timepoint
            toMappings{j}(currID,:) = [NaN,NaN];
        end
        toMappings{j}(bigIDs,1) = toMappings{j}(bigIDs,1) - 1;
    end
end

save(tracksPath,'divisionSettings','toMappings','fromMappings','procTracks','-append')

progressbar(1,debugSet)