%Applies the true values of dt (extracted from imaging metadata) to the
%given tracking dataset (which assumed constant dt, available in the FAST metadata)

clear all
close all

load('C:\Users\olijm\Desktop\Pinging\LongTracks.mat');
load('C:\Users\olijm\Desktop\Pinging\TrackabilityStore.mat')
load('C:\Users\olijm\Desktop\Pinging\Metadata.mat')

realDt = diff(dtStore);
basisDt = metaStore.dt;

%Recalculate velocity measurements on the basis of the more accurate
%metadata recordings
for i = 1:size(procTracks,2)
    for t = 1:size(procTracks(i).x,1)-1
        currT = procTracks(i).times(t);
        thisDt = realDt(currT-1); %-1 accounts for the out-by-one indexing issue with the real version of Dt
        resc = thisDt/basisDt;
        procTracks(i).vmag(t) = procTracks(i).vmag(t) / resc;
    end
end

save('C:\Users\olijm\Desktop\Pinging\Tracks.mat','procTracks','fromMappings','toMappings','trackSettings','trackableData','rawToMappings','rawFromMappings','rawTracks','linkStats','realDt');