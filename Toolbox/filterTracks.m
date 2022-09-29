function procTracks = filterTracks(procTracks,filterField,filterVal,filterDir)
%FILTERTRACKS removes tracks with mean feature values that exceed a
%user-specified threshold.
%
%   INPUTS:
%       -procTracks: The main track output of FAST's tracking module
%       -filterField: String specifying a feature field you wish to use as
%       a filter (e.g. 'vmag','sparefeat1' etc)
%       -filterVal: The value that should not be exceeded for a given track
%       to remain under consideration.
%       -filterDir: Whether you wish to remove tracks below (-1) or above
%       (+1) the specified threshold value.
%
%   OUTPUTS:
%       -procTracks: The set of processed tracks, with tracks that exceed
%       the specified threshold removed.
%
%   Author: Oliver J. Meacock, (c) 2021.

meanVals = arrayfun(@(x)(nanmean(x.(filterField))),procTracks);

switch filterDir
    case +1
        badInds = meanVals > filterVal;
    case -1
        badInds = meanVals < filterVal;
end

procTracks(badInds) = [];