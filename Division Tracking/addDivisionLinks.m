function procTracks = addDivisionLinks(procTracks,linkArray1,linkArray2)
%ADDDIVISIONLINKS converts the linkArray output of the
%doDivisionLinkingRedux function to a format that can be contained within
%the procTracks structure - namely, by adding the fields D1, D2 and M,
%indicating Daughter 1, Daughter 2 and Mother track IDs for each track.
%
%   INPUTS:
%       -procTracks: Tracking data, output of the tracking module and saved
%       in the Tracks.mat file
%   `   -linkArray1: Output of the doDivisionLinkingRedux function,
%       containing assignments between mothers and the first set of
%       daughters.
%       -linkArray2: Same as linkArray1, but for assignments between
%       mothers and the second set of daughters.
%
%   OUTPUTS:
%       -procTracks: Version of procTracks, with the D1, D2 and M fields
%       added or updated.
%
%   Author: Oliver J. Meacock (c) 2019

%Clear out any pre-existing data
for i = 1:size(procTracks,2)
    procTracks(i).M = [];
    procTracks(i).D1 = [];
    procTracks(i).D2 = [];
end

for i = 1:size(linkArray1,1)
    procTracks(linkArray1(i,1)).D1 = linkArray1(i,2);
    procTracks(linkArray1(i,2)).M = linkArray1(i,1);
end

for i = 1:size(linkArray2,1)
    procTracks(linkArray2(i,1)).D2 = linkArray2(i,2);
    procTracks(linkArray2(i,2)).M = linkArray2(i,1);
end

%Create a new 'generational age' field that tells you the age of the cell
%in generations from the start of the lineage.
for i = 1:size(procTracks,2)
    if isempty(procTracks(i).M) %Implies that this is a lineage founding cell
        [linInds,linLens] = getLineageIndices(procTracks,i,0);
        for j = 1:size(linInds,1)
            currInd = linInds(j);
            if ~isempty(procTracks(currInd).D1) || ~isempty(procTracks(currInd).D2) %If this track ends in a division, add a 'fractional generation' to the generational age
                fracAge = procTracks(currInd).age./max(procTracks(currInd).age);
                totAge = linLens(j) + fracAge;
            else
                totAge = ones(size(procTracks(currInd).age))*linLens(j);
            end
            procTracks(currInd).generationalAge = totAge;
        end
    end
end