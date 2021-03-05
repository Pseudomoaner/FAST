function [procTracks,fromMappings,toMappings] = processTracks(rawTracks,fromMappings,toMappings,trackSettings,trackTimes,debugSet)
%PROCESSTRACKS performs post-processing on the tracks generated by the
%earlier stages of the FAST tracking pipeline. Tasks performed: velocity
%calculation (based on positions), removal of short tracks, association of
%sampling timepoints with tracks.
%
%   INPUTS:
%       -rawTracks: initial track format. Should come direct from the
%       'extractDataTrack' function
%       -fromMappings: mapping from the 'track' representation of the data 
%       (i.e. feature values associated with specific tracks) back to the 
%       'slice' representation (i.e. feature values associated with unknown
%       tracks but defined timepoints). 
%       -toMappings: mapping from the original 'slice' representation of the
%       data to the 'track' representation of the data. For more details, see the
%       'extractDataTrack' function. 
%       -trackSettings: settings for tracking, defined within the
%       diffusionTracker GUI
%       -trackTimes: times of track samples, in units of frames
%       -debugSet: whether debugging is currently active
%
%   OUTPUTS:
%       -procTracks: tracks with new fields (vmag, theta, times, length, start,
%       end) defined and short tracks removed
%       -fromMappings: fromMappings with short tracks removed
%       -toMappings: toMappings with short tracks removed
%
%   Author: Oliver J. Meacock, (c) 2019

debugprogressbar([0.8;0;0],debugSet)

trackDataNames = fieldnames(rawTracks);

%Remove all tracks that are shorter than the specified threshold
lengthDist = zeros(size(rawTracks.(trackDataNames{1}),2),1);
for i = 1:length(lengthDist)
    lengthDist(i) = size(rawTracks.(trackDataNames{1}){i},1);
end
shortTracks = find(lengthDist < trackSettings.minTrackLen);

for i = 1:size(trackDataNames,1)
    rawTracks.(trackDataNames{i})(shortTracks) = [];
end

%Rejigging toMappings is a bit more tricky, given the deletion of the
%tracks in the above code causes the position of tracks below them in the
%data structure to shift.
for i = shortTracks'-(0:(size(shortTracks,1)-1)) %For each short track (weird indexing here accounts for the continual subtraction of one from each track index during each run through the loop)
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

trackTimes(shortTracks) = [];
fromMappings(shortTracks) = [];

debugprogressbar([0.8;0.2;0],debugSet)

procTracks = struct();
for i = 1:length(rawTracks.(trackDataNames{1}))
    if isfield(rawTracks,'Centroid')
        
        if size(rawTracks.Centroid{i},1) > 1
            %Do linear interpolation for gap-bridged timepoints. Interpolated
            %timepoints will be marked via the 'interpolated' field.
            procTracks(i).x = interp1(trackTimes{i},rawTracks.Centroid{i}(:,1),trackTimes{i}(1):trackTimes{i}(end))';
            procTracks(i).y = interp1(trackTimes{i},rawTracks.Centroid{i}(:,2),trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).x = rawTracks.Centroid{i}(:,1);
            procTracks(i).y = rawTracks.Centroid{i}(:,2);
        end
        
        if ~exist('RawSpeed','var') || ~exist('RawTheta','var')
            [RawSpeed,RawTheta] = getAllVelocities(rawTracks.Centroid,trackTimes,trackSettings.dt);
        end
        
        procTracks(i).theta = RawTheta{i};
        procTracks(i).vmag = RawSpeed{i};
    end
    if isfield(rawTracks,'Length')
        if size(rawTracks.Length{i},1) > 1
            procTracks(i).majorLen = interp1(trackTimes{i},rawTracks.Length{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).majorLen = rawTracks.Length{i};
        end
    end
    if isfield(rawTracks,'Width')
        if size(rawTracks.Width{i},1) > 1
            procTracks(i).minorLen = interp1(trackTimes{i},rawTracks.Width{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).minorLen = rawTracks.Width{i};
        end
    end
    if isfield(rawTracks,'Area')
        if size(rawTracks.Area{i},1) > 1
            procTracks(i).area = interp1(trackTimes{i},rawTracks.Area{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).area = rawTracks.Area{i};
        end
    end
    if isfield(rawTracks,'Orientation')
        if size(rawTracks.Orientation{i},1) > 1
            %Touch awkward because orientation is a circular statistic
            procTracks(i).phi = interp1Ang(trackTimes{i},rawTracks.Orientation{i},trackTimes{i}(1):trackTimes{i}(end),'linear',-90,90)';
        else
            procTracks(i).phi = rawTracks.Orientation{i};
        end
    end
    if isfield(rawTracks,'ChannelMean')
        for chan = 1:size(rawTracks.ChannelMean{i},2)
            fieldName = ['channel_',num2str(trackSettings.availableMeans(chan)),'_mean'];
            if size(rawTracks.ChannelMean{i},1) > 1
                procTracks(i).(fieldName) = interp1(trackTimes{i},rawTracks.ChannelMean{i}(:,chan),trackTimes{i}(1):trackTimes{i}(end))';
            else
                procTracks(i).(fieldName) = rawTracks.ChannelMean{i}(:,chan);
            end
        end
    end
    if isfield(rawTracks,'ChannelStd')
        for chan = 1:size(rawTracks.ChannelStd{i},2)
            fieldName = ['channel_',num2str(trackSettings.availableStds(chan)),'_std'];
            if size(rawTracks.ChannelStd{i},1) > 1
                procTracks(i).(fieldName) = interp1(trackTimes{i},rawTracks.ChannelStd{i}(:,chan),trackTimes{i}(1):trackTimes{i}(end))';
            else
                procTracks(i).(fieldName) = rawTracks.ChannelStd{i}(:,chan);
            end
        end
    end
    if isfield(rawTracks,'SpareFeat1')
        if size(rawTracks.SpareFeat1{i},1) > 1
            procTracks(i).sparefeat1 = interp1(trackTimes{i},rawTracks.SpareFeat1{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).sparefeat1 = rawTracks.SpareFeat1{i};
        end
    end
    if isfield(rawTracks,'SpareFeat2')
        if size(rawTracks.SpareFeat2{i},1) > 1
            procTracks(i).sparefeat2 = interp1(trackTimes{i},rawTracks.SpareFeat2{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).sparefeat2 = rawTracks.SpareFeat2{i};
        end
    end
    if isfield(rawTracks,'SpareFeat3')
        if size(rawTracks.SpareFeat3{i},1) > 1
            procTracks(i).sparefeat3 = interp1(trackTimes{i},rawTracks.SpareFeat3{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).sparefeat3 = rawTracks.SpareFeat3{i};
        end
    end
    if isfield(rawTracks,'SpareFeat4')
        if size(rawTracks.SpareFeat4{i},1) > 1
            procTracks(i).sparefeat4 = interp1(trackTimes{i},rawTracks.SpareFeat4{i},trackTimes{i}(1):trackTimes{i}(end))';
        else
            procTracks(i).sparefeat4 = rawTracks.SpareFeat4{i};
        end
    end
    procTracks(i).times = trackTimes{i}(1):trackTimes{i}(end);
    procTracks(i).length = size(procTracks(i).times,2);
    procTracks(i).start = trackTimes{i}(1);
    procTracks(i).end = trackTimes{i}(end);
    
    %Find interpolated timepoints and note down in interpolated field
    tDiff = diff(trackTimes{i}) - 1;
    interpolated = zeros(size(trackTimes{i}));
    interpPts = find(tDiff > 0);
    interpLens = tDiff(interpPts);
    for j = 1:size(interpPts,2)
        interpolated = [interpolated(1:(interpPts(j)+sum(interpLens(1:j-1)))),ones(1,interpLens(j)),interpolated(interpPts(j)+sum(interpLens(1:j-1))+1:end)];
    end
    procTracks(i).interpolated = interpolated;
    
    %Insert an 'age' field, indicating the age of the object (time from start
    %of track)
    procTracks(i).age = (procTracks(i).times - procTracks(i).times(1))'*trackSettings.dt;
    
    debugprogressbar([0.8;(i*0.8)/length(rawTracks.(trackDataNames{1})) + 0.2;0],debugSet)
end