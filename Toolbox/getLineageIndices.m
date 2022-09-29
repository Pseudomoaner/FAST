function [linInds,linLens] = getLineageIndices(procTracks,motherID,callDepth)
%GETLINEAGEINDICES is a recursive function that allows you to extract all of
%the indicies from a given tree-structured lineage. Now also returns the 
%distance of each lineage from the founder cell.
%
%   INPUTS:
%       -procTracks: A track structure which has been output by the
%       Divisions module of the FAST GUI. Includes fields D1, D2 and M,
%       indicating the two daughters of this cell and the mother of this
%       cell.
%       -motherID: The ID of the track that is the founder of the current
%       lineage.
%       -callDepth: The current depth into the recursion you are. Starts at
%       0 upon first call.
%
%   OUTPUTS:
%       -linInds: A vector of all the descendants that arise from the initial mother ID
%       -linLens: The distance from the foundational track each track is.
%
%   Author: Oliver J. Meacock, (c) 2019

D1ID = procTracks(motherID).D1;
D2ID = procTracks(motherID).D2;

if ~isempty(D1ID)
    [D1lins,D1lens] = getLineageIndices(procTracks,D1ID,callDepth + 1);
else
    D1lins = [];
    D1lens = [];
end
if ~isempty(D2ID)
    [D2lins,D2lens] = getLineageIndices(procTracks,D2ID,callDepth + 1);
else
    D2lins = [];
    D2lens = [];
end

linInds = [motherID;D1lins;D2lins];
linLens = [callDepth;D1lens;D2lens];