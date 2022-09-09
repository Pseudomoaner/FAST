function [dataTracks,trackTimes,toMappings,fromMappings] = extractModelDataTrack(Track,Initials,data)

trackCount = 1;
dataTracks = {};
trackTimes = {};
fromMappings = {}; %Locations of each cell in the final track format in the original frame-by-frame data format

toMappings = cell(size(data)); %Locations of each cell in the original frame-by-frame data format in the final track format
for i = 1:length(toMappings)
    toMappings{i} = nan(size(data,1),2);
end

for i = 1:length(Track)
    %Find the tracks starting in the current frame
    currInits = find(Initials{i});
    
    for j = 1:length(currInits)
        currTrack = data{i}(currInits(j),:);
        currTimes = i;
        toMappings{i}(currInits(j),:) = [trackCount,size(currTrack,1)]; %Format is trackID, position in list of cells in that track
        nextPos = Track{i}(currInits(j),:);
        currMapping = [i,currInits(j)]; %Format is frame, position in list of cells at that frame
        while ~isnan(nextPos(1))
            currTrack = [currTrack; data{nextPos(1)}(nextPos(2),:)];
            currTimes = [currTimes, nextPos(1)];
            currMapping = [currMapping;nextPos(1),nextPos(2)];
            toMappings{nextPos(1)}(nextPos(2),:) = [trackCount,size(currTrack,1)];
            nextPos = Track{nextPos(1)}(nextPos(2),:);
        end
        dataTracks{trackCount} = currTrack;
        trackTimes{trackCount} = currTimes;
        fromMappings{trackCount} = currMapping;
        trackCount = trackCount + 1;
    end
end