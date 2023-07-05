function procTracks = labelUnusualEvents(procTracks,tgtPop,tgtField,stdThresh,eventLabel)
%LABELUNUSUALEVENTS labels times at which a given track-associated
%quantity moves a specified distance away from its mean, taking into account
%the typical level of fluctuation of the quantity.
%
%   INPUTS:
%       -procTracks: Track data output by the tracking module.
%       -tgtPop: If population assignment has been performed, this variable
%       can be used to specify which of the populations you wish to
%       restrict event detection to. Can be left empty if you wish to apply
%       it to all tracks.
%       -tgtField: String defining the name of the field of procTracks you
%       wish to apply threshold detection to. Can refer to any field,
%       provided it is indexed by time and is one-dimensional (so 'x' and 
%       'vmag' are permissible, but 'start' and 'length' are not).
%       -stdThresh: The number of sigma (standard deviations) away from the
%		track-level mean the field value should be to be marked as an event.
%		The 'sigma' is calculated at the population level.
%       -eventLabel: The integer you wish to use to label this set of
%       events.
%
%   OUTPUTS:
%       -procTracks: Equal to the input procTracks, but either with the
%       'event' field updated, or (if not already present) added, with the
%       appropriate events marked.
%
%   Author: Oliver J. Meacock, (c) 2023

%Needed to ensure you don't overwrite pre-existing event data in procTracks
%later
if isfield(procTracks,'event')
    preFlag = true;
else
    preFlag = false;
end

%Find the amount of variation in the chosen field at the population level
popWideStd = std(vertcat(procTracks.(tgtField)));

for i = 1:size(procTracks,2)    
    if preFlag
        currEvt = procTracks(i).event; %Get pre-existing event list for this track (if it exists)
    else
        currEvt = zeros(size(procTracks(i).x)); %Want to make sure we're using the maximal possible length of the event list (need to avoid using e.g. vmag, which is one shorter than maximum as it is from a differential).
    end
    
    %Want to do processing only if the tgtPop variable is empty OR there is
    %a target population, the population field exists, and the current
    %track is part of the target population
    if isempty(tgtPop)
        proceed = true;
    elseif ~isempty(tgtPop) && isfield(procTracks,'population')
        if procTracks(i).population == tgtPop
            proceed = true;
        else
            proceed = false;
        end
    elseif ~isempty(tgtPop) && ~isfield(procTracks,'population')
        warning('Population specified, but field not present in procTracks. Proceeding without splitting by population...')
        proceed = true;
    end
    
    if proceed
        trkMean = nanmean(procTracks(i).(tgtField));
		outliers = or(procTracks(i).(tgtField) - trkMean > popWideStd*stdThresh,procTracks(i).(tgtField) - trkMean < -popWideStd*stdThresh); %Timepoints where value is further away from mean than fluctuation threshold
        currEvt = currEvt + outliers*eventLabel;
    end
    procTracks(i).event = currEvt;
end